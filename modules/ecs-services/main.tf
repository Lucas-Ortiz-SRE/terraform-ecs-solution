# 2. Criação do Log Group obrigatório para o serviço
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.cluster_name}/${var.service_name}"
  retention_in_days = var.log_retention_in_days
}

# 2. Criação da Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.environment}-container"
      image     = var.container_image
      cpu       = tonumber(var.task_cpu)
      memory    = tonumber(var.task_memory)
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      # Aqui injetamos os ARNs do Secrets Manager automaticamente
      secrets = local.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Application = var.application_tag
    CostCenter  = var.cost_center
  }
}

# 3. Criação do Target Group (Condicional)
resource "aws_lb_target_group" "this" {
  # Só cria se a variável for true
  count = var.create_target_group ? 1 : 0

  name        = "${var.service_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-499"
  }

  tags = {
    Application = var.application_tag
    CostCenter  = var.cost_center
  }
}

# 3.1. Criação da Listener Rule (vincula Target Group ao ALB)
resource "aws_lb_listener_rule" "this" {
  count        = var.create_target_group ? 1 : 0
  listener_arn = var.alb_listener_arn
  priority     = var.alb_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    host_header {
      values = [var.host_header]
    }
  }
}

# 4. Criação do Serviço ECS
resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }

  # O bloco dynamic agora avalia a variável booleana
  dynamic "load_balancer" {
    for_each = var.create_target_group ? [1] : []
    content {
      # Apontamos para o ARN do Target Group criado acima (índice 0 pois usamos count)
      target_group_arn = aws_lb_target_group.this[0].arn
      container_name   = "${var.project_name}-${var.environment}-container"
      container_port   = var.container_port
    }
  }

  tags = {
    Application = var.application_tag
    CostCenter  = var.cost_center
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}