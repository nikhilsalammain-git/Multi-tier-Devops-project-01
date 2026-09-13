variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
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

