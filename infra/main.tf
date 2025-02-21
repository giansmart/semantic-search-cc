terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "local" {}  # O usa S3 si deseas almacenar el estado en AWS
}

provider "aws" {
  region = var.aws_region
}

# Llamamos a los módulos
module "api_gateway" {
  source = "./modules/api_gateway"
  lambda_upload_cv_arn = module.lambda_upload_cv.lambda_arn
  lambda_semantic_search_arn = module.lambda_semantic_search.lambda_arn
  aws_region = var.aws_region
}

module "lambda_layer" {
  source = "./modules/lambda_layer"
}

module "lambda_upload_cv" {
  source = "./modules/lambda_upload_cv"
  api_gateway_id = module.api_gateway.api_gateway_id
  aws_region = var.aws_region
  aws_account_id = "383329440761"
  lambda_layer_arn = module.lambda_layer.lambda_layer_arn 
}

module "lambda_manage_embeddings" {
  source           = "./modules/lambda_manage_embeddings"
  lambda_layer_arn = module.lambda_layer.lambda_layer_arn

  openai_api_key    = var.openai_api_key
  opensearch_host   = var.opensearch_host
  opensearch_user   = var.opensearch_user
  opensearch_pass   = var.opensearch_pass
}

module "lambda_semantic_search" {
  source = "./modules/lambda_semantic_search"
  api_gateway_id = module.api_gateway.api_gateway_id
  aws_region = var.aws_region
  aws_account_id = "383329440761"
  lambda_manage_embeddings_name = module.lambda_manage_embeddings.lambda_name
}

module "iam" {
  source = "./modules/iam"
}