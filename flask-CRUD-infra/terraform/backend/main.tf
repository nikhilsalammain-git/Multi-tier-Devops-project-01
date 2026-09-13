terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.64.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "8byte-nikhil-terraform-state-bucket"

  tags = {
    Name        = "terraform-state-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

terraform {
  backend "s3" {
    bucket       = "8byte-nikhil-terraform-state-bucket"
    key          = "state/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
