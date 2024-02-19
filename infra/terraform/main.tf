terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.36.0" }
  }
  backend "s3" {
    bucket         = "tf-state-096250078731"
    key            = "learning-jenkins/tf-state"
    region         = "eu-central-1"
    dynamodb_table = "tf-state-learning-jenkins"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Needs a provider for the us-east-1 region to create the ACM certificate for cloudfront
provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}
