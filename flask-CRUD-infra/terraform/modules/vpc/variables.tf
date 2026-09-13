variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}
variable "pub_subnet_cidr" {
  description = "Public Subnet CIDR Block"
  type        = list(string)
}

variable "pri_subnet_cidr" {
  description = "Private Subnet CIDR Block"
  type        = list(string)
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks-region" {
  description = "region of the VPC"
  type        = string
}