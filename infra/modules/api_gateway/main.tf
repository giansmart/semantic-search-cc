resource "aws_api_gateway_rest_api" "upload_api" {
  name        = "upload_api"
  description = "API para subir y procesar PDFs"
}

## Endpoint Upload CV
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
  uri         = var.lambda_upload_cv_arn
}


## Endpoint Semantic Search
resource "aws_api_gateway_resource" "search" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  parent_id   = aws_api_gateway_rest_api.upload_api.root_resource_id
  path_part   = "search"
}

resource "aws_api_gateway_method" "post_search" {
  rest_api_id   = aws_api_gateway_rest_api.upload_api.id
  resource_id   = aws_api_gateway_resource.search.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_search" {
  rest_api_id             = aws_api_gateway_rest_api.upload_api.id
  resource_id             = aws_api_gateway_resource.search.id
  http_method             = aws_api_gateway_method.post_search.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_semantic_search_arn
}

## Deployment
resource "aws_api_gateway_stage" "upload_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.upload_api.id
  deployment_id = aws_api_gateway_deployment.upload_deployment.id
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
    aws_api_gateway_integration.lambda_upload_cv,
    aws_api_gateway_method.post_search,
    aws_api_gateway_integration.lambda_search
  ]
}

## Configuración CORS para la ruta /search

resource "aws_api_gateway_method" "options_search" {
  rest_api_id   = aws_api_gateway_rest_api.upload_api.id
  resource_id   = aws_api_gateway_resource.search.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_search_integration" {
  rest_api_id             = aws_api_gateway_rest_api.upload_api.id
  resource_id             = aws_api_gateway_resource.search.id
  http_method             = aws_api_gateway_method.options_search.http_method
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_search_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.options_search.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}


resource "aws_api_gateway_integration_response" "options_search_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.options_search.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.options_search_integration,
    aws_api_gateway_method_response.options_search_response  # ✅ Agregada la dependencia correcta
    # aws_api_gateway_method_response.options_method_response
  ] 
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}

## Configurar CORS en la respuesta del `POST /search`
resource "aws_api_gateway_method_response" "post_search_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.post_search.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "post_search_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.post_search.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.lambda_search,
    aws_api_gateway_method_response.post_search_response
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

## Configuración CORS para la ruta /upload

resource "aws_api_gateway_method" "options_upload" {
  rest_api_id   = aws_api_gateway_rest_api.upload_api.id
  resource_id   = aws_api_gateway_resource.upload.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_upload_integration" {
  rest_api_id             = aws_api_gateway_rest_api.upload_api.id
  resource_id             = aws_api_gateway_resource.upload.id
  http_method             = aws_api_gateway_method.options_upload.http_method
  type                    = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_upload_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.options_upload.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}



resource "aws_api_gateway_integration_response" "options_upload_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.options_upload.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.options_upload_integration,
    aws_api_gateway_method_response.options_upload_response  # ✅ Agregada la dependencia correcta
    # aws_api_gateway_method_response.options_method_response
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }
}


## Configurar CORS en la respuesta del `POST /upload`
resource "aws_api_gateway_method_response" "post_upload_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.post_upload.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "post_upload_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_api.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.post_upload.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.lambda_upload_cv,
    aws_api_gateway_method_response.post_upload_response  # ✅ Agregada dependencia correcta
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}