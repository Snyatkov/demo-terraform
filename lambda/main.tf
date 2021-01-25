resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_role_s3_read.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role" "lambda_role_s3_read" {
  name = "lambda_role_s3_read"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "with_lb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_read_S3.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = var.tg_for_demo_lambda
}

resource "aws_lambda_alias" "lambda_read_s3_alias" {
  name             = "lambda_read_s3_alias"
  function_name    = aws_lambda_function.lambda_read_S3.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_function" "lambda_read_S3" {
  role             = aws_iam_role.lambda_role_s3_read.arn
  handler          = "lambda.handler"
  runtime          = "python3.6"
  filename         = "lambda.zip"
  function_name    = "lambda_read_S3"
  source_code_hash = filebase64sha256("lambda.zip")
}
