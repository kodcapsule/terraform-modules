terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}


module "static-S3-Website-bucket" {
    source = "./modules/static-S3-Website-bucket"
    s3-bucket-name = "kodecapsule-website-101"

    tags = {
      Environment:"DEV"
    }
}