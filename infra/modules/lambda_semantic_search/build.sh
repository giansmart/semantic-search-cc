#!/bin/bash

set -e  # 🚨 Detener ejecución si hay un error

# 📌 Configurar variables
PACKAGE_DIR="infra/modules/lambda_semantic_search/package"
SERVICE_DIR=services/semantic_search

echo "📌 Eliminando archivos anteriores..."
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

# 📌 Instalar dependencias en la Lambda
pip install --upgrade -r "$SERVICE_DIR"/requirements.txt -t "$PACKAGE_DIR"

# 📌 Copiar el código fuente
cp "$SERVICE_DIR"/index.py "$PACKAGE_DIR"

# 📌 Comprimir el ZIP
cd "$PACKAGE_DIR" && zip -r "../lambda_semantic_search.zip" .

echo "✅ Lambda ZIP generado correctamente."