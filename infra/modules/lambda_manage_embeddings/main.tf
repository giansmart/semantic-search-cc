resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    command = <<EOT
      rm -rf ${path.module}/package ${path.module}/lambda_manage_embeddings.zip
      mkdir -p ${path.module}/package
      pip install --upgrade -r ${path.root}/../services/manage_embeddings/requirements.txt -t ${path.module}/package/
      cp ${path.root}/../services/manage_embeddings/index.py ${path.module}/package/
      ls -la ${path.module}/package/
      cd ${path.module}/package && zip -r ../lambda_manage_embeddings.zip .
    EOT
  }
}

resource "aws_lambda_function" "lambda_manage_embeddings" {
  function_name    = "manage_embeddings_lambda"
  handler         = "index.lambda_handler"
  runtime         = "python3.9"
  role            = aws_iam_role.lambda_role.arn
  filename        = "${path.module}/lambda_manage_embeddings.zip"
  timeout         = 60

  layers = [var.lambda_layer_arn]

  environment {
    variables = {
      OPENAI_API_KEY    = var.openai_api_key
      OPENSEARCH_HOST   = var.opensearch_host
      OPENSEARCH_USER   = var.opensearch_user
      OPENSEARCH_PASS   = var.opensearch_pass
    }
  }

  depends_on = [null_resource.package_lambda]
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_manage_embeddings_role"
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

