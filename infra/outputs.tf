output "url_upload_api" {
  #value = "https://${module.api_gateway.api_gateway_id}.execute-api.${var.aws_region}.amazonaws.com/${module.api_gateway.api_gateway_stage_name}"
  value = module.api_gateway.upload_endpoint
}

output "search_api_url" {
  value = module.api_gateway.search_endpoint
}