resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    command = <<EOT
      rm -rf ${path.module}/package ${path.module}/lambda_semantic_search.zip
      mkdir -p ${path.module}/package
      pip install --upgrade -r ${path.root}/../services/semantic_search/requirements.txt -t ${path.module}/package/
      cp ${path.root}/../services/semantic_search/index.py ${path.module}/package/
      cd ${path.module}/package && zip -r ../lambda_semantic_search.zip .
    EOT
  }
}

resource "aws_lambda_function" "lambda_semantic_search" {
  function_name    = "semantic_search_lambda"
  handler         = "index.lambda_handler"
  runtime         = "python3.9"
  role            = aws_iam_role.lambda_role.arn
  filename        = "${path.module}/lambda_semantic_search.zip"
  timeout         = 60

  environment {
    variables = {
      MANAGE_EMBEDDINGS_LAMBDA = var.lambda_manage_embeddings_name
    }
  }

  depends_on = [null_resource.package_lambda]
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_semantic_search_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_semantic_search.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${var.api_gateway_id}/*/*"
}

resource "aws_iam_policy" "invoke_manage_embeddings" {
  name        = "InvokeManageEmbeddingsPolicy2"
  description = "Permite a semantic_search invocar la función manage_embeddings"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:manage_embeddings_lambda"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "semantic_search_invoke_manage_embeddings" {
  policy_arn = aws_iam_policy.invoke_manage_embeddings.arn
  role       = aws_iam_role.lambda_role.name
}
