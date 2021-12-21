resource "aws_lambda_function" "lambda_func" {
  function_name = "generate_pre_signed_s3_url"
  handler = "publish_presigned_url_lambda.lambda_handler"
  role          = aws_iam_role.presigned_url_iam_role.arn
  runtime = "python3.9"
  filename = data.archive_file.lambda_zip_file.output_path
  layers = ["arn:aws:lambda:eu-central-1:770693421928:layer:Klayers-python38-aws-xray-sdk:100"]
  timeout = 5
}

data "archive_file" "lambda_zip_file" {
  output_path = "/tmp/lambda_zip_file_int.zip"
  type = "zip"
  source {
    content = file("./files/publish_presigned_url_lambda.py")
    filename = "publish_presigned_url_lambda.py"
  }
}

resource "aws_lambda_function" "email_lambda" {
  function_name = "email_lambda"
  handler = "email_lambda.lambda_handler"
  role          = aws_iam_role.send_email_iam_role.arn
  runtime = "python3.9"
  filename = data.archive_file.lambda_email_zip.output_path
  layers = ["arn:aws:lambda:eu-central-1:770693421928:layer:Klayers-python38-aws-xray-sdk:100"]
  timeout = 5
  environment {
    variables = {
      FROM_ADDRESS = var.from_address
      TO_ADDRESSES = var.to_addresses
    }
  }
}

data "archive_file" "lambda_email_zip" {
  output_path = "/tmp/lambda_email.zip"
  type = "zip"
  source {
    content = file("./files/email_lambda.py")
    filename = "email_lambda.py"
  }
}


resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowIoTRuleToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.iot_rule_url_topic.arn
}

resource "aws_lambda_permission" "allow_s3_lambda" {
  statement_id  = "AllowS3ToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    =aws_s3_bucket.s3_bucket.arn
}

