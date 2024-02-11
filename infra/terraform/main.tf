terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.36.0" }
  }
  //TODO Move backend to S3
}

provider "aws" {
  region = "eu-central-1"
}