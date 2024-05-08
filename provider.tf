terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}

# Needed because CloudFront can only use ACM certs generated in us-east-1
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
