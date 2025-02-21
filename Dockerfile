# 🔹 Usamos Amazon Linux 2 (compatibilidad con AWS Lambda x86_64)
FROM amazonlinux:2

# 🔹 Instalar Python y pip
RUN yum install -y python3 pip zip && pip3 install --upgrade pip

# 🔹 Crear directorio para el Layer
WORKDIR /lambda_layer
RUN mkdir -p python

# 🔹 Instalar `pdfminer.six` en la carpeta `python/`
RUN pip3 install --only-binary=:all: --no-deps pdfminer.six cryptography -t python/

# 🔹 Comprimir el Layer en un ZIP
RUN zip -r /tmp/pdfminer_layer.zip python/