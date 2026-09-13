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

terraform {
  backend "s3" {
    bucket       = "8byte-nikhil-terraform-state-bucket"
    key          = "state/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

module "vpc" {
  source = "./modules/vpc"

  eks-region       = var.eks_region
  vpc_cidr         = var.vpc_cidr
  azs              = var.azs
  pri_subnet_cidr  = var.pri_subnet_cidr
  pub_subnet_cidr  = var.pub_subnet_cidr
  eks_cluster_name = var.eks_cluster_name
}
module "eks" {
  source = "./modules/eks"

  region             = var.eks_region
  eks_cluster_name   = var.eks_cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.VPC_ID
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  node_group         = var.node_group
}
