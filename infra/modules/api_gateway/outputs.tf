output "api_gateway_id" {
  value = aws_api_gateway_rest_api.upload_api.id
}

output "api_gateway_stage_name" {
  value = aws_api_gateway_stage.upload_stage.stage_name
}