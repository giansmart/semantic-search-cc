
resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    command = <<EOT
      rm -rf ${path.module}/package ${path.module}/lambda_upload.zip
      mkdir -p ${path.module}/package
      echo "Ruta de requirements.txt: ${path.root}/services/upload_cv/requirements.txt"
      ls -la ${path.root}/../services/upload_cv/
      pip install --upgrade -r ${path.root}/../services/upload_cv/requirements.txt -t ${path.module}/package/
      cp ${path.root}/../services/upload_cv/index.py ${path.module}/package/
      echo "Contenido de package/:"
      ls -la ${path.module}/package/
      cd ${path.module}/package && zip -r ../lambda_upload.zip .
    EOT
  }
}

resource "aws_lambda_function" "lambda_upload_cv" {
  function_name    = "upload_cv_lambda"
  handler         = "index.lambda_handler"
  runtime         = "python3.9"
  role            = aws_iam_role.lambda_role.arn
  filename        = "${path.module}/lambda_upload.zip"
  timeout         = 60

  source_code_hash = filebase64sha256("${path.module}/lambda_upload.zip") 

  depends_on = [null_resource.package_lambda]
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_upload_role"
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
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_upload_cv.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${var.api_gateway_id}/*/*"
}