terraform {
  required_version = "~> 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65.0"
    }
  }
}


provider "aws" {
  region = "eu-central-1"
}
