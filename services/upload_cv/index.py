import json
import base64
import fitz  # pymupdf
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        # Verificar si el body contiene el archivo
        body = json.loads(event["body"])
        if "file" not in body:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "No file provided"})
            }

        # Decodificar el archivo PDF desde Base64
        pdf_bytes = base64.b64decode(body["file"])

        # Leer el texto del PDF con PyMuPDF
        text = extract_text_from_pdf(pdf_bytes)

        # Imprimir en los logs de AWS CloudWatch
        logger.info("Texto extraído del PDF:\n" + text)

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Texto extraído correctamente", "text": text[:500]})  # Enviar solo los primeros 500 caracteres
        }

    except Exception as e:
        logger.error(f"Error procesando el PDF: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

def extract_text_from_pdf(pdf_bytes):
    """
    Extrae el texto de un archivo PDF en bytes.
    """
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    text = "\n".join(page.get_text() for page in doc)
    return text