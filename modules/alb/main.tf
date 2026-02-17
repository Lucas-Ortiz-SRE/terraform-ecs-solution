#=============================================================================================
# APPLICATION LOAD BALANCER
#=============================================================================================
# Cria o Application Load Balancer (ALB) para distribuir tráfego entre os ECS services
# Pode ser interno (apenas VPC) ou internet-facing (público)
resource "aws_lb" "this" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

#=============================================================================================
# HTTPS LISTENER
#=============================================================================================
# Listener HTTPS (porta 443) com certificado SSL/TLS
# Ação padrão retorna 404 (services específicos criam suas próprias regras)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}

#=============================================================================================
# HTTP LISTENER (REDIRECT TO HTTPS)
#=============================================================================================
# Listener HTTP (porta 80) que redireciona todo tráfego para HTTPS (porta 443)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
