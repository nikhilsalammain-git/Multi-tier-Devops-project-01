variable "eks_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string


}


variable "pub_subnet_cidr" {
  description = "public subnet CIDR block"
  type        = list(string)

}


variable "pri_subnet_cidr" {
  description = "private subnet CIDR block"
  type        = list(string)

}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "node_group" {
  description = "Configuration for the EKS node group"
  type = map(object({
    scaling_config = object({
      desired_capacity = number
      max_capacity     = number
      min_capacity     = number
    })
    instance_type = string
    capacity_type = string
  }))
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "rds_identifier" {
  description = "RDS instance identifier."
  type        = string
  default     = "eight-byte-postgres"
}

variable "rds_engine" {
  description = "RDS database engine."
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.4"
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS storage size in GiB."
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "flaskdb"
}

variable "rds_username" {
  description = "RDS master username."
  type        = string
  default     = "flaskadmin"
}

variable "rds_password" {
  description = "RDS master password. Supply through TF_VAR_rds_password."
  type        = string
  sensitive   = true
  default     = "admin123"
}

variable "rds_publicly_accessible" {
  description = "Whether the RDS instance receives a public IP."
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip the final snapshot when destroying the RDS instance."
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Protect the RDS instance from deletion."
  type        = bool
  default     = false
}
