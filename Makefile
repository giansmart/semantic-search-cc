.PHONY: all upload_cv manage_embeddings layer build deploy clean

# 🟢 Build de todas las Lambdas y el Layer
all: layer upload_cv manage_embeddings semantic_search

# 🟢 Build del Layer
layer:
	@echo "📌 Construyendo Lambda Layer..."
	./infra/modules/lambda_layer/build_layer.sh

# 🟢 Build de upload_cv
upload_cv:
	@echo "📌 Construyendo Lambda upload_cv..."
	./infra/modules/lambda_upload_cv/build.sh

# 🟢 Build de manage_embeddings
manage_embeddings:
	@echo "📌 Construyendo Lambda manage_embeddings..."
	./infra/modules/lambda_manage_embeddings/build.sh

semantic_search:
	@echo "📌 Construyendo Lambda semantic_search..."
	./infra/modules/lambda_semantic_search/build.sh

# 🟢 Ejecutar Terraform para desplegar todo
deploy: all
	@echo "📌 Aplicando Terraform..."
	cd infra && terraform apply -auto-approve -var-file="terraform.tfvars"

# 🟢 Limpiar archivos ZIP y paquetes generados
clean:
	@echo "📌 Eliminando archivos generados..."
	rm -rf infra/modules/lambda_layer/python infra/modules/lambda_layer/lambda_layer.zip
	rm -rf infra/modules/lambda_upload_cv/package infra/modules/lambda_upload_cv/lambda_upload.zip
	rm -rf infra/modules/lambda_manage_embeddings/package infra/modules/lambda_manage_embeddings/lambda_manage_embeddings.zip
	rm -rf infra/modules/lambda_semantic_search/package infra/modules/lambda_semantic_search/lambda_semantic_search.zip