output "api_gateway_id" {
  value = aws_api_gateway_rest_api.upload_api.id
}

output "api_gateway_stage_name" {
  value = aws_api_gateway_stage.upload_stage.stage_name
}

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.upload_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.upload_stage.stage_name}"
}

output "search_endpoint" {
  value = "https://${aws_api_gateway_rest_api.upload_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.upload_stage.stage_name}/search"
}