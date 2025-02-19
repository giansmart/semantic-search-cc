output "lambda_arn" {
  value = aws_lambda_function.lambda_upload_cv.invoke_arn
}