#
# Create the single security group to manage traffic to RDS.
#
resource "aws_security_group" "rds_sg" {
  name   = "${var.environment}-${var.app_name}-rds-sg"
  vpc_id = var.vpc_id

  tags = {
    Application = var.app_name
    Billing     = var.environment
    Environment = var.environment
    Name        = "${var.environment}-${var.app_name}-rds-sg"
    Terraform   = true
  }
}

#
# Create all of the rules for this security group.
#
resource "aws_security_group_rule" "rds_egress_all" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rds_ingress" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  self              = true
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rds_ingress_mysql" {
  cidr_blocks       = var.ingress_cidr_blocks
  from_port         = 3306
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  to_port           = 3306
  type              = "ingress"
}

resource "aws_security_group_rule" "rds_ingress_mysql_from_home" {
  cidr_blocks       = ["66.182.197.254/32"]
  from_port         = 3306
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  to_port           = 3306
  type              = "ingress"
}
