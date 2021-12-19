variable "s3_bucket_name" {
  type        = string
  default     = "motion-detection-bucket"
  description = "The S3 bucket name where the DAGs and startup scripts will be stored, leave this blank to let this module create a s3 bucket for you. WARNING: this module will put files into the path \"dags/\" and \"startup/\" of the bucket"
}


variable "certificate" {
  default = "arn:aws:iot:eu-central-1:827625524425:cert/4cedd98246f63557e628961b52c4eef9752db053e2ba282f1bf3bb3305e007bf"
}

variable "region" {
  type        = string
  description = "The region to deploy your solution to"
  default     = "eu-central-1"
}

variable "from_address" {
  type = string
  description = "The from email address which sends the notifications.\nThis email address needs to be verified on SES https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-addresses-and-domains.html"
}

variable "to_addresses" {
  type        = string
  description = "Email addresses which should receive the link to the video"
}

output "iot_endpoint_url" {
  value = aws_iot_thing.iot_thing
}