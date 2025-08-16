terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}