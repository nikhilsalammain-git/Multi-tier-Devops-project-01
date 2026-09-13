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

module "rds" {
  source = "./modules/rds"

  identifier          = var.rds_identifier
  engine              = var.rds_engine
  engine_version      = var.rds_engine_version
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  db_name             = var.rds_db_name
  username            = var.rds_username
  password            = var.rds_password
  vpc_id              = module.vpc.VPC_ID
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [var.vpc_cidr]
  publicly_accessible = var.rds_publicly_accessible
  skip_final_snapshot = var.rds_skip_final_snapshot
  deletion_protection = var.rds_deletion_protection
}

output "rds_endpoint" {
  description = "RDS endpoint hostname."
  value       = module.rds.endpoint
}

output "rds_connection_string" {
  description = "PostgreSQL connection string for the Flask application."
  value       = module.rds.connection_string
  sensitive   = true
}
