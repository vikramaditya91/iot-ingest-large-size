resource "aws_iot_thing" "iot_thing" {
  name = "vikram-rpi3"
}

resource "aws_iot_policy" "pubsub" {
  name = "rpi3-policy"

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