resource "aws_s3_bucket" "s3_bucket" {
  bucket = "vikram-detection-bucket"
  acl    = "private"

  versioning {
    enabled = false
  }
}


