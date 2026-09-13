eks_region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

pub_subnet_cidr = [
  "10.0.1.0/24",
  "10.0.2.0/24",
]

pri_subnet_cidr = [
  "10.0.11.0/24",
  "10.0.12.0/24",
]

azs = [
  "us-east-1a",
  "us-east-1b",
]

eks_cluster_name = "8byte-eks"
cluster_version  = "1.33"

node_group = {
  general = {
    scaling_config = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
    instance_type = "t3.small"
    capacity_type = "ON_DEMAND"
  }
}
