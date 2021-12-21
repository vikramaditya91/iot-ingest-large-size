resource "aws_iam_role_policy" "presigned_url_iam_role_policy" {
  name = "presigned_url_iam_role_policy"
  role   = aws_iam_role.presigned_url_iam_role.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      {
        Effect="Allow",
        Action=[
          "iot:Publish",
        ],
        Resource=["arn:aws:iot:${var.region}:${local.account_id}:topic/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iam_role_lambda_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.presigned_url_iam_role.name
}
resource "aws_iam_role" "presigned_url_iam_role" {
  name               = "presigned_url_iam_role"
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
  name = "send_email_iam_role_policy"
  role   = aws_iam_role.presigned_url_iam_role.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      {
        Effect="Allow",
        Action=[
          "s3:GetObject"
        ],
        Resource=["*"]
      }
    ]
  })
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
        Resource=[
          "arn:aws:iot:${var.region}:${local.account_id}:cacert/*",
          "arn:aws:iot:${var.region}:${local.account_id}:client/*",
          "arn:aws:iot:${var.region}:${local.account_id}:topic*/*",
          "arn:aws:iot:${var.region}:${local.account_id}:thing*/*"
        ]
      }
    ]
  })
}

