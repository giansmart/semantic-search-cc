#!/bin/bash

set -e  # 🚨 Detener ejecución si hay un error

# 📌 Configurar variables
LAYER_DIR="infra/modules/lambda_layer/python"

echo "📌 Eliminando archivos anteriores..."
rm -rf "$LAYER_DIR" lambda_layer.zip
mkdir -p "$LAYER_DIR"

# 📌 Instalar dependencias en el Layer
pip install --upgrade -r "$(dirname "$0")/../../../services/upload_cv/requirements.txt" -t "$LAYER_DIR"
pip install --upgrade -r "$(dirname "$0")/../../../services/manage_embeddings/requirements.txt" -t "$LAYER_DIR"

# 📌 Comprimir el Layer
# cd infra/modules/lambda_layer && zip -r ../lambda_layer.zip python/
cd infra/modules/lambda_layer && zip -r lambda_layer.zip python/

echo "✅ Lambda Layer ZIP generado correctamente."