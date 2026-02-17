#=============================================================================================
# SECURITY GROUP PARA ALB
#=============================================================================================
resource "aws_security_group" "alb" {
  count = var.create_alb && var.create_alb_security_group ? 1 : 0

  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

#=============================================================================================
# SECURITY GROUPS PARA ECS SERVICES
#=============================================================================================
resource "aws_security_group" "ecs_service" {
  for_each = { for k, v in var.ecs_services : k => v if v.create_security_group }

  name        = "${var.project_name}-${var.environment}-${each.key}-sg"
  description = "Security group for ECS service ${each.key}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-${each.key}-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}
