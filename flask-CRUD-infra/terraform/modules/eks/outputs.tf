output "eks-cluster-endpoint" {
    description = "eks-cluster-endpoint"
    value = aws_eks_cluster.main.endpoint
}
