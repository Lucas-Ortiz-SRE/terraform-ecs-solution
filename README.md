# Terraform ECS Solution

Módulo Terraform completo para provisionamento de infraestrutura AWS ECS (Elastic Container Service) com Application Load Balancer (ALB), VPC, Security Groups e IAM Roles.

## Descrição

Este repositório contém uma solução modular e flexível para criar e gerenciar infraestrutura de containers na AWS usando ECS Fargate. O módulo foi projetado para ser altamente configurável, permitindo desde a criação completa de uma nova infraestrutura até a integração com recursos já existentes.

## Características Principais

- **Modularidade**: Arquitetura baseada em módulos independentes e reutilizáveis
- **Flexibilidade**: Suporte para criar novos recursos ou usar recursos existentes
- **Segurança**: Security Groups configuráveis com opção de criar novos ou usar existentes
- **Alta Disponibilidade**: Distribuição automática de recursos em múltiplas Availability Zones
- **Circuit Breaker**: Proteção contra deployments com falhas através de rollback automático
- **Observabilidade**: Integração com CloudWatch Logs para monitoramento de containers
- **Secrets Management**: Suporte nativo para AWS Secrets Manager

## Estrutura do Repositório

```
terraform-ecs-solution/
├── main.tf                 # Arquivo principal que orquestra todos os módulos
├── variables.tf            # Definição de todas as variáveis de entrada
├── outputs.tf              # Outputs dos recursos criados
├── terraform.tfvars        # Arquivo de exemplo com valores das variáveis
├── modules/                # Módulos Terraform organizados por funcionalidade
│   ├── vpc/               # Criação de VPC, subnets, NAT Gateway, Internet Gateway
│   ├── security-groups/   # Security Groups para ALB e ECS Services
│   ├── iam-roles/         # IAM Roles para execução e tasks do ECS
│   ├── ecs-cluster/       # Cluster ECS
│   ├── alb/               # Application Load Balancer e Listener HTTPS
│   └── ecs-services/      # ECS Services, Task Definitions e Target Groups
└── examples/              # Exemplos de configuração para diferentes cenários
    ├── 01-create-all-resources.tfvars
    ├── 02-use-existing-resources.tfvars
    ├── 03-existing-vpc-new-resources.tfvars
    ├── 04-existing-vpc-cluster-new-alb.tfvars
    └── 05-existing-infra-new-security-groups.tfvars
```

## Recursos Criados

### Opcionais (baseado na configuração)

- **VPC**: Virtual Private Cloud com subnets públicas, privadas e data
- **NAT Gateway**: Para permitir acesso à internet das subnets privadas
- **Internet Gateway**: Para acesso à internet das subnets públicas
- **ECS Cluster**: Cluster para agrupar os serviços ECS
- **Application Load Balancer**: Load balancer com listener HTTPS
- **Security Groups**: Grupos de segurança para ALB e ECS Services

### Sempre Criados

- **ECS Services**: Serviços que executam os containers
- **Task Definitions**: Definições das tasks com configurações de CPU, memória e containers
- **Target Groups**: Grupos de destino para roteamento do ALB
- **Listener Rules**: Regras de roteamento baseadas em host header
- **CloudWatch Log Groups**: Grupos de logs para cada serviço
- **IAM Roles**: Roles de execução e task para os serviços ECS

## Pré-requisitos

- Terraform >= 1.0
- AWS CLI configurado com credenciais válidas
- Certificado SSL/TLS no AWS Certificate Manager (ACM) para HTTPS
- Imagens Docker publicadas no Amazon ECR (Elastic Container Registry)

## Como Usar

### 1. Escolha o Cenário Adequado

O repositório oferece 5 exemplos de configuração na pasta `examples/`:

**Exemplo 1 - Criar Todos os Recursos do Zero (Greenfield)**
- Cria: VPC, Cluster, ALB, Security Groups e Services
- Ideal para: Novos projetos, ambientes isolados, PoCs

**Exemplo 2 - Usar Recursos Existentes (Brownfield)**
- Usa: VPC, Cluster, ALB e Security Groups existentes
- Cria: Apenas os ECS Services
- Ideal para: Adicionar services em infraestrutura existente

**Exemplo 3 - VPC Existente + Criar Novos Recursos**
- Usa: VPC existente
- Cria: Cluster, ALB, Security Groups e Services
- Ideal para: VPC compartilhada entre times

**Exemplo 4 - VPC e Cluster Existentes + Criar ALB Novo**
- Usa: VPC e Cluster existentes
- Cria: ALB, Security Groups e Services
- Ideal para: Separar ALBs por tipo de aplicação

**Exemplo 5 - Infraestrutura Existente + Criar Security Groups Novos**
- Usa: VPC, Cluster e ALB existentes
- Cria: Security Groups e Services
- Ideal para: Isolamento de segurança entre aplicações

### 2. Configure as Variáveis

Copie o exemplo desejado para o arquivo `terraform.tfvars`:

```bash
cp examples/01-create-all-resources.tfvars terraform.tfvars
```

Edite o arquivo `terraform.tfvars` e ajuste os valores conforme seu ambiente:

```hcl
environment  = "production"
project_name = "myapp"
aws_region   = "us-east-1"

# Configure os demais parâmetros conforme necessário
```

### 3. Execute o Terraform

Inicialize o Terraform:

```bash
terraform init
```

Visualize o plano de execução:

```bash
terraform plan
```

Aplique as mudanças:

```bash
terraform apply
```

Para usar um arquivo de variáveis específico:

```bash
terraform plan -var-file="examples/01-create-all-resources.tfvars"
terraform apply -var-file="examples/01-create-all-resources.tfvars"
```

### 4. Destruir Recursos

Para remover todos os recursos criados:

```bash
terraform destroy
```

## Variáveis Principais

### Globais

- `environment`: Ambiente de deploy (development, staging, production, qa)
- `project_name`: Nome do projeto (máximo 20 caracteres)
- `aws_region`: Região AWS onde os recursos serão criados

### VPC

- `create_vpc`: Define se cria nova VPC ou usa existente
- `vpc_id`: ID da VPC existente (obrigatório se create_vpc=false)
- `vpc_cidr`: Bloco CIDR da VPC (ex: 10.0.0.0/16)
- `availability_zones_count`: Número de AZs (1-3)

### ECS Cluster

- `create_ecs_cluster`: Define se cria novo cluster ou usa existente
- `ecs_cluster_id`: ARN do cluster existente
- `ecs_cluster_name`: Nome do cluster existente

### Application Load Balancer

- `alb_listener_arn`: ARN do listener existente (vazio para criar novo)
- `certificate_arn`: ARN do certificado SSL/TLS no ACM
- `create_alb_security_group`: Define se cria novo SG para ALB
- `alb_internal`: Define se ALB é interno (true) ou público (false)

### ECS Services

- `container_image`: URL da imagem Docker no ECR
- `container_port`: Porta que o container expõe
- `task_cpu`: vCPU da task (256, 512, 1024, 2048, 4096)
- `task_memory`: Memória em MB (512, 1024, 2048, 4096, 8192)
- `desired_count`: Número de tasks desejadas
- `create_security_group`: Define se cria novo SG para o service
- `create_target_group`: Define se cria target group (true para APIs, false para workers)

## Arquitetura

### Fluxo de Tráfego

```
Internet → ALB (Subnets Públicas) → Target Group → ECS Tasks (Subnets Privadas)
```

### Componentes

1. **VPC**: Rede isolada com subnets públicas e privadas em múltiplas AZs
2. **ALB**: Recebe tráfego HTTPS e distribui para os containers
3. **ECS Cluster**: Agrupa os serviços ECS
4. **ECS Services**: Gerenciam a execução dos containers
5. **Task Definitions**: Definem como os containers devem ser executados
6. **Security Groups**: Controlam o tráfego de rede
7. **IAM Roles**: Permissões para execução e acesso a recursos AWS

## Segurança

### Security Groups

O módulo cria Security Groups com as seguintes características:

- **ALB Security Group**: Permite tráfego de entrada na porta 443 (HTTPS)
- **ECS Service Security Groups**: Permite tráfego apenas do ALB na porta do container
- Todas as regras de saída (egress) permitem tráfego para qualquer destino

### IAM Roles

Cada ECS Service recebe duas roles:

- **Execution Role**: Permite ao ECS baixar imagens do ECR e enviar logs ao CloudWatch
- **Task Role**: Permite ao container acessar outros serviços AWS (S3, DynamoDB, etc)

### Secrets Management

Suporte para injeção de secrets do AWS Secrets Manager diretamente nas variáveis de ambiente dos containers.

## Circuit Breaker

Todos os ECS Services são criados com Circuit Breaker habilitado:

- Detecta automaticamente falhas em deployments
- Realiza rollback automático para a versão anterior estável
- Evita loop infinito de tasks falhando

## Observabilidade

### CloudWatch Logs

Cada ECS Service possui seu próprio Log Group no CloudWatch:

- Padrão de nomenclatura: `/ecs/{cluster-name}/{service-name}`
- Retenção configurável (1, 3, 5, 7, 14, 30 dias ou mais)
- Logs estruturados com prefixo "ecs"

## Limitações e Considerações

### Limites da AWS

- Nome do Target Group: máximo 32 caracteres
- Prioridade do ALB Listener Rule: deve ser única por listener (1-50000)
- Task CPU e Memory: devem seguir combinações válidas do Fargate

### Custos

Os principais recursos que geram custos:

- NAT Gateway (se habilitado)
- Application Load Balancer
- ECS Tasks (baseado em vCPU e memória)
- Data Transfer
- CloudWatch Logs

### Boas Práticas

- Use `nat_gateway_ha = false` para ambientes de desenvolvimento (mais econômico)
- Configure `log_retention_in_days = 1` para testes (reduz custos)
- Use `task_cpu = "256"` e `task_memory = "512"` para cargas leves
- Sempre configure health checks adequados para suas aplicações
- Use tags consistentes para rastreamento de custos

## Troubleshooting

### Tasks não iniciam

- Verifique se as subnets privadas têm acesso à internet via NAT Gateway
- Confirme que a imagem Docker existe no ECR
- Verifique os logs no CloudWatch

### ALB retorna 503

- Verifique se o health check está configurado corretamente
- Confirme que o container está respondendo na porta configurada
- Verifique os Security Groups

### Deployment falha

- O Circuit Breaker fará rollback automático
- Verifique os logs do CloudWatch para identificar o erro
- Confirme que a nova task definition está correta

## Contribuindo

Contribuições são bem-vindas. Por favor:

1. Faça fork do repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT.

## Suporte

Para dúvidas ou problemas:

- Abra uma issue no repositório
- Consulte a documentação oficial da AWS
- Revise os exemplos na pasta `examples/`

## Referências

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
