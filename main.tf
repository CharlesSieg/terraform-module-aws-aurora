provider "aws" {
  alias = "dnsProvider"
}

resource "aws_db_subnet_group" "default" {
  name       = "private_data_subnets" # cannot change this name without creating a new aurora cluster
  subnet_ids = concat(var.private_subnets, var.public_subnets)

  tags = {
    Application = var.app_name
    Billing     = "${var.environment}-${var.app_name}"
    Environment = var.environment
    Name        = "${var.environment}-${var.app_name}-aurora-cluster-subnet-group"
    Terraform   = true
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  #apply_immediately    = true
  cluster_identifier   = aws_rds_cluster.cluster.id
  count                = var.replica_count
  db_subnet_group_name = aws_db_subnet_group.default.name
  engine               = var.engine
  identifier_prefix    = "${var.environment}-${var.app_name}-db"
  instance_class       = var.db_instance_class
  publicly_accessible  = true

  tags = {
    Application = var.app_name
    Billing     = "${var.environment}-${var.app_name}"
    Environment = var.environment
    Name        = "${var.environment}-${var.app_name}-db${count.index}"
    Terraform   = true
  }
}

#
# Obtain the master username and password from AWS Secrets Manager.
#
data "aws_secretsmanager_secret" "aurora_master_pwd" {
  name = "${var.environment}-${var.app_name}-aurora-pwd"
}

data "aws_secretsmanager_secret_version" "aurora_master_pwd" {
  secret_id = data.aws_secretsmanager_secret.aurora_master_pwd.id
}

data "aws_secretsmanager_secret" "aurora_master_user" {
  name = "${var.environment}-${var.app_name}-aurora-user"
}

data "aws_secretsmanager_secret_version" "aurora_master_user" {
  secret_id = data.aws_secretsmanager_secret.aurora_master_user.id
}

resource "aws_rds_cluster" "cluster" {
  availability_zones     = var.availability_zones
  cluster_identifier     = "${var.environment}-${var.app_name}-aurora"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  deletion_protection    = true
  engine                 = var.engine
  master_password        = data.aws_secretsmanager_secret_version.aurora_master_pwd.secret_string
  master_username        = data.aws_secretsmanager_secret_version.aurora_master_user.secret_string
  port                   = 3306
  skip_final_snapshot    = true
  vpc_security_group_ids = concat([aws_security_group.rds_sg.id], var.additional_security_groups)

  tags = {
    Application = var.app_name
    Billing     = "${var.environment}-${var.app_name}"
    Environment = var.environment
    Name        = "${var.environment}-${var.app_name}-aurora-cluster"
    Terraform   = true
  }
}
