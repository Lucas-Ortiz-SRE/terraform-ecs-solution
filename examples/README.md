# Examples

Esta pasta contém exemplos de configuração do módulo Terraform ECS Solution.

## Exemplos Disponíveis

### 1. [01-create-all-resources.tfvars](./01-create-all-resources.tfvars)
**Cenário: Criar todos os recursos do zero (Greenfield)**

Este exemplo demonstra como criar uma infraestrutura completa:
- Nova VPC com subnets públicas, privadas e data
- Novo ECS Cluster
- Novo Application Load Balancer (ALB)
- Novos Security Groups para ALB e ECS Services
- ECS Services com tasks Fargate

**Ideal para:**
- Novos projetos
- Ambientes isolados
- Proof of Concepts (PoC)

---

### 2. [02-use-existing-resources.tfvars](./02-use-existing-resources.tfvars)
**Cenário: Usar recursos existentes (Brownfield)**

Este exemplo demonstra como integrar com infraestrutura existente:
- VPC existente
- ECS Cluster existente
- ALB existente
- Security Groups existentes
- Cria apenas os ECS Services

**Ideal para:**
- Adicionar novos services em infraestrutura existente
- Ambientes compartilhados
- Migração gradual

---

### 3. [03-existing-vpc-new-resources.tfvars](./03-existing-vpc-new-resources.tfvars)
**Cenário: VPC existente + criar novos recursos**

Este exemplo demonstra um cenário híbrido comum:
- VPC existente
- Novo ECS Cluster
- Novo ALB
- Novos Security Groups
- ECS Services com tasks Fargate

**Ideal para:**
- VPC compartilhada entre times
- Multi-tenant com isolamento por aplicação
- Compliance
- Migração gradual para ECS

---

### 4. [04-existing-vpc-cluster-new-alb.tfvars](./04-existing-vpc-cluster-new-alb.tfvars)
**Cenário: VPC e Cluster existentes + criar ALB novo**

Este exemplo demonstra separação de ALBs:
- VPC existente
- ECS Cluster existente
- Novo ALB
- Novos Security Groups
- ECS Services com tasks Fargate

**Ideal para:**
- Separar APIs públicas de APIs internas
- Múltiplos ALBs no mesmo cluster
- Isolamento de tráfego por domínio
- Diferentes certificados SSL por aplicação

---

### 5. [05-existing-infra-new-security-groups.tfvars](./05-existing-infra-new-security-groups.tfvars)
**Cenário: Infraestrutura existente + criar Security Groups novos**

Este exemplo demonstra isolamento de segurança:
- VPC existente
- ECS Cluster existente
- ALB existente
- Novos Security Groups
- ECS Services com tasks Fargate

**Ideal para:**
- Adicionar services com requisitos de segurança diferentes
- Isolamento de rede entre aplicações
- Compliance e auditoria
- Testes de novas regras de segurança

---

## Como Usar

1. Copie o exemplo desejado para o diretório raiz:
```bash
cp examples/01-create-all-resources.tfvars terraform.tfvars
```

2. Ajuste os valores conforme seu ambiente:
   - IDs de recursos existentes (VPC, subnets, security groups, etc)
   - ARNs de certificados ACM
   - URLs de imagens Docker no ECR
   - Domínios e configurações específicas

3. Execute o Terraform:
```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Tabela Comparativa

| Exemplo | VPC | Cluster | ALB | SGs | Caso de Uso |
|---------|-----|---------|-----|-----|-------------|
| **1** |  Nova |  Novo |  Novo |  Novos | Greenfield / PoC |
| **2** |  Existente |  Existente |  Existente |  Existentes | Adicionar services |
| **3** |  Existente |  Novo |  Novo |  Novos | VPC compartilhada |
| **4** |  Existente |  Existente |  Novo |  Novos | Separar ALBs |
| **5** |  Existente |  Existente |  Existente |  Novos | Isolamento de segurança |
