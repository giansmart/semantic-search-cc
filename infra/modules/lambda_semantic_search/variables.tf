variable "api_gateway_id" {
  description = "ID de API Gateway"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "aws_account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}

variable "lambda_manage_embeddings_name" {
  description = "Nombre de la función Lambda manage_embeddings"
  type        = string
}
