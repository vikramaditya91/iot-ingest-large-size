resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.s3_bucket_name
  acl           = "public-read"
  force_destroy = true

  versioning {
    enabled = false
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "PUBLIC_ACCESS_S3_Bucket"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = [
          aws_s3_bucket.s3_bucket.arn,
          "${aws_s3_bucket.s3_bucket.arn}/*",
        ]
      },
    ]
  })
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.email_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_lambda]
}
