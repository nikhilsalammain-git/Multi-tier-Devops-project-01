output "VPC_ID" {
  description = "The ID of the VPC."
  value       = aws_vpc.byte_eks_vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = aws_subnet.private_subnet[*].id
}