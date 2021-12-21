resource "aws_iot_thing" "iot_thing" {
  name = "individual-thing"
}

resource "aws_iot_policy_attachment" "att" {
  policy = aws_iot_policy.pubsub.name
  target = var.certificate
}

resource "aws_iot_topic_rule" "iot_rule_url_topic" {
  name        = var.request_url_topic
  enabled     = true
  sql         = "SELECT * FROM '${var.request_url_topic}'"
  sql_version = "2016-03-23"
  depends_on  = [aws_lambda_function.lambda_func]

  lambda {
    function_arn = aws_lambda_function.lambda_func.arn
  }

}
