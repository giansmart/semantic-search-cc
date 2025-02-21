import base64
import sys

def pdf_to_base64(pdf_path, output_path="files/pdf_base64.txt"):
    """
    Convierte un archivo PDF a una cadena Base64 y la guarda en un archivo de texto.
    
    Args:
        pdf_path (str): Ruta del archivo PDF.
        output_path (str): Ruta del archivo donde se guardará la cadena Base64.
    """
    try:
        with open(pdf_path, "rb") as pdf_file:
            encoded_string = base64.b64encode(pdf_file.read()).decode("utf-8")
        
        with open(output_path, "w") as output_file:
            output_file.write(encoded_string)
        
        print(f"✅ PDF convertido a Base64 y guardado en: {output_path}")
        print(f"📌 Copia este contenido y úsalo en Postman.")
    
    except Exception as e:
        print(f"❌ Error: {str(e)}")

# 🟢 Usar con: python3 utils/pdf_to_base64.py documento.pdf
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("❌ Debes proporcionar la ruta de un PDF.")
        sys.exit(1)
    
    pdf_to_base64(sys.argv[1])