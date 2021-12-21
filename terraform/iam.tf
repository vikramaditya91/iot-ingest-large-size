resource "aws_iam_role_policy" "presigned_url_iam_role_policy" {
  name   = "presigned_url_iam_role_policy"
  role   = aws_iam_role.presigned_url_iam_role.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "iot:Publish",
        ]
        # Can fix the topic name to what is in the send_large_file.py for extra security
        Resource = ["arn:aws:iot:${var.region}:${local.account_id}:topic/*"]
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
        ]
        Resource = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_att_presigned_url" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.presigned_url_iam_role.name
}
resource "aws_iam_role" "presigned_url_iam_role" {
  name               = "presigned_url"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "send_email_iam_role_policy" {
  name   = "send_email_iam_role_policy"
  role   = aws_iam_role.send_email_iam_role.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject"
        ],
        Resource = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
      },
      {
        Effect   = "Allow",
        Action   = [
          "ses:SendEmail"
        ],
        Resource = ["arn:aws:ses:${var.region}:${local.account_id}:identity/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_att_send_email" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.send_email_iam_role.name
}

resource "aws_iam_role" "send_email_iam_role" {
  name               = "send_email_iam_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iot_policy" "pubsub" {
  name = "iot-pub-sub-policy"

  # This policy is used for both publish and receive.
  # Consider splitting it
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive",
        ],
        Resource = [
          "arn:aws:iot:${var.region}:${local.account_id}:cacert/*",
          "arn:aws:iot:${var.region}:${local.account_id}:client/*",
          "arn:aws:iot:${var.region}:${local.account_id}:topic*/*",
          "arn:aws:iot:${var.region}:${local.account_id}:thing*/*"
        ]
      }
    ]
  })
}

