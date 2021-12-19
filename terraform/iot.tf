resource "aws_iot_thing" "iot_thing" {
  name = "individual-thing"
}

resource "aws_iot_policy" "pubsub" {
  name = "iot-pub-sub-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iot:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iot_policy_attachment" "att" {
  policy = aws_iot_policy.pubsub.name
  target = var.certificate
}


resource "aws_iot_topic_rule" "iot_rule_url_topic" {
  name        = "url_topic"
  enabled     = true
  sql         = "SELECT * FROM 'url_topic'"
  sql_version = "2016-03-23"
  depends_on = [aws_lambda_function.lambda_func]

lambda {
    function_arn = aws_lambda_function.lambda_func.arn
}

}

data "aws_iot_endpoint" "iot_endpoint" {}
