#=============================================================================================
# GLOBAL VARIABLES
#=============================================================================================
# enviroment: valores permitidos (production, stage, qa, development)
# project_name: nome do projeto
# aws_region = valores permitidos (us-east-1, us-east-2, sa-east-1)
#=============================================================================================
environment  = "prod"
project_name = "pagamentos"
aws_region   = "us-east-1"

#=============================================================================================
# ECS SERVICES VARIABLES
#=============================================================================================
# enviroment: valores permitidos (production, stage, qa, development)
# project_name: nome do projeto
# aws_region = valores permitidos (us-east-1, us-east-2, sa-east-1)
#=============================================================================================
ecs_services = {
  
  # ---------------------------------------------------------
  # Aplicação 1: API Exposta (Com Load Balancer e Secrets)
  # ---------------------------------------------------------
  "api-pagamentos" = {
    container_name  = "api-app"
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api-pagamentos:v1.2.0"
    
    # Decisões explícitas de arquitetura
    container_port  = 3000
    task_cpu        = "512"
    task_memory     = "1024"
    desired_count   = 2
    
    subnets         = ["subnet-0a1b2c3d", "subnet-0e4f5g6h"]
    security_groups = ["sg-0123456789abcdef0"]
    
    # Integração direta com AWS Secrets Manager
    secrets = [
      { 
        name      = "DB_PASSWORD"
        valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db_password-xyz123" 
      },
      { 
        name      = "API_KEY_PAGAMENTO"
        valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/api_key-abc456" 
      }
    ]

    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/api-tg/xyz"
  }

  # ---------------------------------------------------------
  # Aplicação 2: Worker Interno (Sem Load Balancer)
  # ---------------------------------------------------------
  "worker-processamento" = {
    container_name  = "worker-app"
    container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/worker-proc:v2.0.1"
    
    # Mesmo sendo interno, a porta do contêiner e recursos precisam ser declarados
    container_port  = 8080 
    task_cpu        = "256"
    task_memory     = "512"
    desired_count   = 1
    
    subnets         = ["subnet-0a1b2c3d", "subnet-0e4f5g6h"]
    security_groups = ["sg-0987654321fedcba0"]
    
    # Declarado explicitamente como vazio
    secrets          = []
    target_group_arn = "" 
  }
}