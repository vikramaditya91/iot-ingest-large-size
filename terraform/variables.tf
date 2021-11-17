// S3 Bucket
variable "s3_bucket_name" {
  default     = "vikram-detection-bucket"
}

variable "certificate" {
  default = "arn:aws:iot:eu-central-1:827625524425:cert/4cedd98246f63557e628961b52c4eef9752db053e2ba282f1bf3bb3305e007bf"
}
