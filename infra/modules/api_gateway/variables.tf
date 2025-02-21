variable "lambda_upload_cv_arn" {
  description = "ARN de la función Lambda de upload_cv"
  type        = string
}

variable "lambda_semantic_search_arn" {
  description = "ARN de la función Lambda de semantic_search"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}