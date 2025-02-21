output "lambda_layer_arn" {
  value = aws_lambda_layer_version.lambda_dependencies.arn
}