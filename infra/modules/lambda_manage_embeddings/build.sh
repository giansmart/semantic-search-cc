#!/bin/bash

set -e  # 🚨 Detener ejecución si hay un error

# 📌 Configurar variables
PACKAGE_DIR="infra/modules/lambda_manage_embeddings/package"
SERVICE_DIR="services/manage_embeddings"

echo "📌 Eliminando archivos anteriores..."
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

# 📌 Instalar TODAS las dependencias en la carpeta `package/`
pip install --upgrade -r "$SERVICE_DIR"/requirements.txt -t "$PACKAGE_DIR"

# 📌 Copiar `index.py` dentro del paquete
cp "$SERVICE_DIR"/index.py "$PACKAGE_DIR"/

# 📌 Verificar contenido antes de comprimir
echo "✅ Contenido de package/:"
ls -la "$PACKAGE_DIR"

# 📌 Crear el ZIP
cd "$PACKAGE_DIR" && zip -r ../lambda_manage_embeddings.zip .

echo "✅ Lambda ZIP generado correctamente en infra/modules/lambda_upload_cv/lambda_upload.zip"