#AWS IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.eks_cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

#Attaching the AmazonEKSClusterPolicy to the EKS Cluster Role
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}   

#Main EKS Cluster Resource
resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn
    vpc_config {
        subnet_ids = var.public_subnet_ids
    }
    depends_on = [
        aws_iam_role_policy_attachment.cluster_policy
    ]
} 

#AWS IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_group_role" {
    name = "${var.eks_cluster_name}-node-group-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

#Attach required policies to the EKS Node Group Role
resource "aws_iam_role_policy_attachment" "node_group_policy" {
    for_each = toset([
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    ])
    policy_arn = each.value
    role       = aws_iam_role.eks_node_group_role.name
}

#Create the EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
    for_each = var.node_group
    cluster_name    = aws_eks_cluster.main.name
    node_group_name = each.key
    node_role_arn   = aws_iam_role.eks_node_group_role.arn
    subnet_ids      = var.private_subnet_ids

    scaling_config {
        desired_size = each.value.scaling_config.desired_capacity
        max_size     = each.value.scaling_config.max_capacity
        min_size     = each.value.scaling_config.min_capacity
    }

    instance_types = [each.value.instance_type]
    capacity_type  = each.value.capacity_type

    depends_on = [
        aws_iam_role_policy_attachment.node_group_policy
    ]
}
