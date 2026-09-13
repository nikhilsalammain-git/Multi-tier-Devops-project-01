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
