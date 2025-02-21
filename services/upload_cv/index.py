import json
import base64
import io
import os
import re
from pypdf import PdfReader
import boto3

LAMBDA_CLIENT = boto3.client("lambda")

def invoke_manage_embeddings(applicant_name, text):
    """Llama a la Lambda `manage_embeddings` con el texto extraído"""
    response = LAMBDA_CLIENT.invoke(
        FunctionName="manage_embeddings_lambda",
        InvocationType="Event",
        Payload=json.dumps({"body": json.dumps({"nombre": applicant_name, "texto": text, "accion": "guardar_data"})}),
    )
    return response

def lambda_handler(event, context):
    try:
        print("📌 Iniciando procesamiento...")
        # 🟢 Verificar si el archivo fue enviado correctamente
        if "body" not in event:
            return {"statusCode": 400, "body": json.dumps("No file uploaded")}


        # 🟢 Decodificar JSON del body (porque contiene otro JSON adentro)
        body_json = json.loads(event["body"]) if isinstance(event["body"], str) else event["body"]

        if "body" not in body_json:
            return {"statusCode": 400, "body": json.dumps("No Base64 data found in the request")}
        
        applicant_name = body_json.get("applicant_name")
        if not applicant_name:
            return {"statusCode": 400, "body": json.dumps("No `applicant_name` found in the request")}

        print(f'📄 applicant_name: {applicant_name}')

        # 🟢 Extraer el contenido Base64 correctamente
        pdf_base64 = body_json["body"]
        print(f'📄 Base64 recibido (primeros 100 caracteres): {pdf_base64[:100]}')

        # 🟢 Decodificar Base64
        buffer = base64.b64decode(pdf_base64)
        print(f'📂 Buffer decodificado (primeros 100 bytes): {buffer[:100]}')

        # 🟢 Convertir el buffer en un archivo en memoria
        f = io.BytesIO(buffer)
        print("✅ Buffer convertido a archivo en memoria")

        # 🟢 Leer el PDF
        reader = PdfReader(f)
        print("📄 PDF cargado correctamente")

        if len(reader.pages) == 0:
            return {"statusCode": 400, "body": json.dumps("Error: PDF vacío")}

        page = reader.pages[0]
        extracted_text = page.extract_text() or "No se encontró texto en la primera página"

        print(f"📜 Texto extraído: {extracted_text[:200]}...")  # Mostrar los primeros 200 caracteres

        # 🔹 Invocar la Lambda `manage_embeddings`
        invoke_manage_embeddings(applicant_name, extracted_text)

        print("✅ Procesamiento completado")

        return {
            "statusCode": 200,
            "body": json.dumps({"extracted_text": f"{extracted_text[:500]}..."}),  # Enviar solo los primeros 500 caracteres
        }

    except Exception as e:
        print("❌ Error procesando PDF:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error procesando PDF: {str(e)}")
        }