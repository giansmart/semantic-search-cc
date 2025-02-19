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
  lambda_arn = module.lambda_upload_cv.lambda_arn
  aws_region = var.aws_region
}

module "lambda_upload_cv" {
  source = "./modules/lambda_upload_cv"
  api_gateway_id = module.api_gateway.api_gateway_id
  aws_region = var.aws_region
  aws_account_id = "383329440761"
}

module "lambda_semantic_search" {
  source = "./modules/lambda_semantic_search"
}

module "iam" {
  source = "./modules/iam"
}