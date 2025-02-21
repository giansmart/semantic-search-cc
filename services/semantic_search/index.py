import json
import os
import boto3

# 🔹 Configuración de la Lambda `manage_embeddings`
MANAGE_EMBEDDINGS_LAMBDA = os.getenv("MANAGE_EMBEDDINGS_LAMBDA")

# 🔹 Configurar cliente de AWS Lambda
lambda_client = boto3.client("lambda")

def lambda_handler(event, context):
    """Recibe datos de API Gateway y ejecuta búsqueda en `manage_embeddings`."""
    try:
        print(f"📌 Recibiendo evento: {event}")
        
        # 🔹 Leer datos del request
        body = json.loads(event["body"])
        puesto = body.get("puesto", "")
        descripcion_puesto = body.get("descripcion_puesto", "")
        n_resultados = body.get("n_resultados", 5)

        # 🔹 Validaciones
        if not puesto or not descripcion_puesto:
            return {"statusCode": 400, "body": json.dumps({"error": "Faltan parámetros requeridos"})}

        # 🔹 Concatenar los textos
        consulta_texto = f"{puesto}. {descripcion_puesto}"

        # 🔹 Invocar la Lambda `manage_embeddings`
        response = lambda_client.invoke(
            FunctionName=MANAGE_EMBEDDINGS_LAMBDA,
            InvocationType="RequestResponse",
            Payload=json.dumps({
                "body": json.dumps({
                    "accion": "busqueda_semantica",
                    "descripcion": consulta_texto,
                    "k_resultados": n_resultados
                })
            })
        )

        # 🔹 Obtener la respuesta
        response_payload = json.loads(response["Payload"].read().decode("utf-8"))

        return {
            "statusCode": 200,
            "body": response_payload["body"]
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }