resource "null_resource" "package_layer" {
  provisioner "local-exec" {
    command = <<EOT
      ls -la ${path.module}
      ${path.module}/build_layer.sh
    EOT
  }
}

resource "aws_lambda_layer_version" "lambda_dependencies" {
  layer_name          = "lambda_dependencies"
  compatible_runtimes = ["python3.9"]
  filename            = "${path.module}/lambda_layer.zip"

  depends_on = [null_resource.package_layer]
}