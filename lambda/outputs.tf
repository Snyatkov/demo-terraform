output "lambda_arn" {
  value = aws_lambda_function.lambda_read_S3.arn
}
output "lambda_permission" {
  value = "aws_lambda_permission.with_lb"
}
