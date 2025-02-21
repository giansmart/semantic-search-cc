#!/bin/bash

set -e  # 🚨 Detener ejecución si hay un error

# 📌 Configurar variables
LAYER_NAME="pdfminer-layer"
PACKAGE_DIR="lambda_layer"
ZIP_FILE="$PACKAGE_DIR/pdfminer_layer.zip"
CONTAINER_NAME="lambda-layer-builder"

echo "📌 Paso 1: Eliminando archivos anteriores..."
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

# 📌 Paso 2: Construir la imagen Docker
echo "📌 Paso 2: Construyendo la imagen Docker..."
# docker build -t "$CONTAINER_NAME" .
docker build --platform linux/amd64 -t "$CONTAINER_NAME" .

# 📌 Paso 3: Ejecutar el contenedor y generar el ZIP (Forzamos x86_64)
echo "📌 Paso 3: Generando el ZIP dentro del contenedor..."
# docker run --name "$CONTAINER_NAME" "$CONTAINER_NAME" bash -c "cp /lambda_layer/pdfminer_layer.zip /tmp/"
# docker run --rm --platform linux/amd64 --name "$CONTAINER_NAME" "$CONTAINER_NAME" bash -c "cp /lambda_layer/pdfminer_layer.zip /tmp/"
# docker run --rm --platform linux/amd64 --name "$CONTAINER_NAME" "$CONTAINER_NAME" bash -c "ls -lh /tmp/ && cp /tmp/pdfminer_layer.zip /tmp/"
docker create --platform linux/amd64 --name temp_container "$CONTAINER_NAME"


# 📌 Paso 4: Copiar el ZIP del contenedor a la máquina
echo "📌 Paso 4: Copiando el ZIP desde el contenedor..."
# docker cp "$CONTAINER_NAME":/tmp/pdfminer_layer.zip "$ZIP_FILE"
# docker cp /lambda_layer/pdfminer_layer.zip:/lambda_layer/pdfminer_layer.zip "$ZIP_FILE"
docker cp temp_container:/tmp/pdfminer_layer.zip "$ZIP_FILE"

docker rm -f temp_container


# 📌 Paso 5: Verificar que el ZIP se copió correctamente
if [ -f "$ZIP_FILE" ]; then
  echo "✅ ZIP generado en: $ZIP_FILE"
else
  echo "❌ ERROR: No se generó el ZIP correctamente"
  exit 1
fi

# 📌 Paso 6: Subir el ZIP a AWS Lambda como un Layer
echo "📌 Paso 6: Subiendo el ZIP a AWS Lambda..."
LAYER_ARN=$(aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --description "Layer with pdfminer.six for PDF processing" \
  --compatible-runtimes python3.9 \
  --zip-file fileb://"$ZIP_FILE" \
  --region us-east-1 \
  --query 'LayerVersionArn' --output text)

if [ -n "$LAYER_ARN" ]; then
  echo "✅ Layer subido correctamente: $LAYER_ARN"
  echo "📌 Copia este ARN y agrégalo en Terraform:"
  echo "layers = [\"$LAYER_ARN\"]"
else
  echo "❌ ERROR: No se pudo subir el Layer a AWS"
  exit 1
fi