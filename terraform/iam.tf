resource "aws_iam_role" "generic_iam_lambda_role" {
  name = "test_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}


resource "aws_iam_role_policy" "iam_policy_for_lambda" {
  name = "mypolicy"
  role = aws_iam_role.generic_iam_lambda_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "*"
        ],
        "Resource": "*"
    }
  ]
}
EOF
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


