resource "aws_api_gateway_rest_api" "upload_api" {
  name        = "upload_api"
  description = "API para subir y procesar PDFs"
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  parent_id   = aws_api_gateway_rest_api.upload_api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "post_upload" {
  rest_api_id   = aws_api_gateway_rest_api.upload_api.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_upload_cv" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.post_upload.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = var.lambda_arn
}

resource "aws_api_gateway_deployment" "upload_deployment" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.upload_api))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.post_upload, 
    aws_api_gateway_integration.lambda_upload_cv
  ]
}

resource "aws_api_gateway_stage" "upload_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.upload_api.id
  deployment_id = aws_api_gateway_deployment.upload_deployment.id
}