import json
import os
import boto3
import requests
from requests.auth import HTTPBasicAuth

# Cargar variables desde Lambda (configurar en AWS)
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
OPENSEARCH_HOST = os.getenv("OPENSEARCH_HOST")
OPENSEARCH_USER = os.getenv("OPENSEARCH_USER")
OPENSEARCH_PASS = os.getenv("OPENSEARCH_PASS")
INDEX_NAME = "semantic-search-db"

def get_openai_embedding(text):
    """Genera embeddings usando OpenAI"""
    url = "https://api.openai.com/v1/embeddings"
    headers = {"Authorization": f"Bearer {OPENAI_API_KEY}", "Content-Type": "application/json"}
    payload = {"input": text, "model": "text-embedding-ada-002"}

    response = requests.post(url, headers=headers, json=payload)
    response_data = response.json()

    if "data" in response_data:
        return response_data["data"][0]["embedding"]
    else:
        raise Exception(f"Error en OpenAI API: {response_data}")


def store_in_opensearch(nombre, texto, embeddings):
    """Almacena el texto y su embedding en OpenSearch"""

    if isinstance(embeddings, list):
        embeddings = [float(x) for x in embeddings]  # ✅ Convertir a floats para evitar problemas

    document = {
        "nombre": nombre,
        "texto": texto,
        "embeddings": embeddings  # ✅ Ahora se almacena como una lista de números
    }

    url = f"{OPENSEARCH_HOST}/{INDEX_NAME}/_doc"
    
    response = requests.post(url, auth=HTTPBasicAuth(OPENSEARCH_USER, OPENSEARCH_PASS), json=document)
    if response.status_code not in [200, 201]:
        raise Exception(f"Error al guardar en OpenSearch: {response.text}")
    
    return response.json()

def save_data(nombre, texto):
    if not texto or not nombre:
            return {"statusCode": 400, "body": json.dumps(f"Missing params: nombre = '{nombre}', texto = '{texto}'")}

    embeddings = get_openai_embedding(texto)
    print('embeddings', embeddings)
    store_result = store_in_opensearch(nombre, texto, embeddings)

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Embedding stored", "opensearch_response": store_result}),
    }

def semantic_search(descripcion, k_resultados):
    """Realiza búsqueda semántica en OpenSearch utilizando similitud del coseno"""
    try:
        print("Ejecutando busqueda semantica")
        query_embedding = get_openai_embedding(descripcion)
        print("query_embedding", query_embedding)
        # 🟢 Consulta a OpenSearch con similitud del coseno
        query = {
            "size": k_resultados,
            "query": {
                "knn": {
                    "embeddings": {
                        "vector": query_embedding,  # 🔥 Embedding de la consulta
                        "k": k_resultados
                    }
                }
            }
        }
        # 🟢 Enviar la consulta a OpenSearch
        url = f"{OPENSEARCH_HOST}/{INDEX_NAME}/_search"
        response = requests.post(url, auth=HTTPBasicAuth(OPENSEARCH_USER, OPENSEARCH_PASS), json=query)

        if response.status_code != 200:
            raise Exception(f"Error en búsqueda: {response.text}")

        search_results = response.json()

        # 🟢 Extraer los resultados relevantes
        hits = search_results.get("hits", {}).get("hits", [])
        resultados = [
            {
                "nombre": hit["_source"]["nombre"],
                "texto": hit["_source"]["texto"],
                "score": hit["_score"]
            }
            for hit in hits
        ]

        return {
            "statusCode": 200,
            "body": json.dumps({"resultados": resultados})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error en búsqueda semántica: {str(e)}")
        }

def lambda_handler(event, context):
    """Maneja la invocación desde `upload_cv`"""
    try:
        print(f"starting... {event}")
        body = json.loads(event.get("body"))

        accion = body.get("accion")
        if accion == "guardar_data":
            nombre = body.get("nombre", "")
            texto = body.get("texto", "")
            return save_data(nombre, texto)

        elif accion == "busqueda_semantica":
            descripcion = body.get("descripcion")
            k_resultados = int(body.get("k_resultados"))
            return semantic_search(descripcion, k_resultados)

        else:
            return {"statusCode": 400, "body": json.dumps(f"Missing params: accion = '{accion}'")}

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps(f"Error: {str(e)}")}