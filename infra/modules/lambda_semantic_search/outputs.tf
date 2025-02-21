output "lambda_arn" {
  value = aws_lambda_function.lambda_semantic_search.invoke_arn
}