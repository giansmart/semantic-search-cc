variable "aws_region" {
  description = "Región de AWS donde se desplegarán los servicios"
  type        = string
  default     = "us-east-1"  # Cambia esto si usas otra región
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