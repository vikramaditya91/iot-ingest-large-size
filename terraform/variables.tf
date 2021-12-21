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
  type        = string
  description = "The from email address which sends the notifications.\nThis email address needs to be verified on SES https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-addresses-and-domains.html"
}

variable "to_addresses" {
  type        = string
  description = "Email addresses which should receive the link to the video"
}

variable "request_url_topic" {
  type        = string
  description = "Request pre-signed by pub to this topic. This needs to match with the variable in send_large_file.py"
  default     = "request_url_topic"
}

variable "lambda_layer_with_boto3" {
  type        = string
  description = "Choose a lambda layer from here which contains the boto3 package. \nIt is regularly updated here https://github.com/keithrozario/Klayers/blob/master/deployments/python3.8/arns/eu-central-1.csv"
  default     = "arn:aws:lambda:eu-central-1:770693421928:layer:Klayers-python38-aws-xray-sdk:100"
}


data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}