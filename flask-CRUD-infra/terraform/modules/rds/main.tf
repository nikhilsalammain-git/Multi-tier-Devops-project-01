resource "aws_security_group" "rds" {
  name        = "${var.identifier}-sg"
  description = "Allow PostgreSQL traffic from the application VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from the VPC"
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.allowed_cidr_blocks
  }

  tags = {
    Name = "${var.identifier}-sg"
  }
}

resource "aws_kms_key" "rds_storage" {
  description         = "KMS key for RDS storage encryption"
  enable_key_rotation = true
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.identifier}-subnet-group"
  }
}

resource "aws_db_instance" "rds" {
  identifier              = var.identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = "gp3"
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  port                    = 5432
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  publicly_accessible     = var.publicly_accessible
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds_storage.arn
  multi_az                = false
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  backup_retention_period = 1

  tags = {
    Name = var.identifier
  }
}