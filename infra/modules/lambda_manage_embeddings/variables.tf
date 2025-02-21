variable "lambda_layer_arn" {
  description = "ARN del Lambda Layer con dependencias"
  type        = string
}

variable "openai_api_key" {
  description = "Clave API de OpenAI"
  type        = string
  sensitive   = true
}

variable "opensearch_host" {
  description = "Endpoint de OpenSearch"
  type        = string
  sensitive   = true
}

variable "opensearch_user" {
  description = "Usuario de OpenSearch"
  type        = string
  sensitive   = true
}

variable "opensearch_pass" {
  description = "Contraseña de OpenSearch"
  type        = string
  sensitive   = true
}