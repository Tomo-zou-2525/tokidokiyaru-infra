terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # TODO: アカウント名修正
    bucket         = "stg-terraform-state-428485887053"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "stg-terraform-state-locktable"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      env       = "stg"
      service   = "tokidokiyaru"
      Terraform = true
    }
  }
}
