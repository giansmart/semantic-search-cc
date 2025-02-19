#!/bin/bash

# 🔹 1. Configurar variables
PACKAGE_DIR="$(pwd)/package"  # 📦 Ahora está dentro del mismo módulo
SERVICE_DIR="$(pwd)/../../../services/upload_cv"  # 📂 Ruta al código fuente

echo "📌 Instalando dependencias en: $PACKAGE_DIR"
echo "📌 Código fuente en: $SERVICE_DIR"

# ls -la "$PACKAGE_DIR"

# 🔹 2. Eliminar paquetes previos
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

# 🔹 3. Ejecutar Docker con Amazon Linux 2 para instalar pymupdf
docker run --rm -v "$PACKAGE_DIR":/package -v "$SERVICE_DIR":/service --platform linux/amd64 amazonlinux:2 bash -c "
  yum install -y python3 pip &&
  pip3 install --upgrade pip &&
  pip3 install --upgrade -r requirements.txt -t /package
"

echo "✅ Archivos instalados en package/:"
ls -la "$PACKAGE_DIR"

# 🔹 4. Copiar `index.py` dentro del paquete
cp "$(pwd)/../../../services/upload_cv/index.py" "$PACKAGE_DIR"/

# 🔹 5. Verificar contenido antes de comprimir
echo "✅ Contenido de package/:"
ls -la "$PACKAGE_DIR"

rm -f $(pwd)/lambda_upload.zip

# 🔹 6. Crear ZIP para Terraform
cd "$PACKAGE_DIR" && zip -r ../lambda_upload.zip .
echo "✅ ZIP generado en: $(pwd)/../lambda_upload.zip"