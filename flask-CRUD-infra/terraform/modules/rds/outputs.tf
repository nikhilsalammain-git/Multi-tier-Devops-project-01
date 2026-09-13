output "endpoint" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.rds.address
}

output "port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.rds.port
}

output "connection_string" {
  description = "PostgreSQL connection string for the Flask application."
  value       = "postgresql://${var.username}:${var.password}@${aws_db_instance.rds.address}:${aws_db_instance.rds.port}/${var.db_name}"
  sensitive   = true
}