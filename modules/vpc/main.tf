#=============================================================================================
# VPC
#=============================================================================================
# Cria a VPC com DNS habilitado
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

#=============================================================================================
# INTERNET GATEWAY
#=============================================================================================
# Gateway para permitir acesso à internet das subnets públicas
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && var.create_public_subnets ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

#=============================================================================================
# SUBNETS PÚBLICAS
#=============================================================================================
# Subnets públicas distribuídas em múltiplas AZs (para ALB)
resource "aws_subnet" "public" {
  count = var.create_vpc && var.create_public_subnets ? var.availability_zones_count : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-${local.azs[count.index]}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "public"
  }
}

#=============================================================================================
# SUBNETS PRIVADAS
#=============================================================================================
# Subnets privadas distribuídas em múltiplas AZs (para ECS tasks)
resource "aws_subnet" "private" {
  count = var.create_vpc && var.create_private_subnets ? var.availability_zones_count : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-${local.azs[count.index]}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
  }
}

#=============================================================================================
# SUBNETS DATA
#=============================================================================================
# Subnets data distribuídas em múltiplas AZs (para RDS, ElastiCache, etc)
resource "aws_subnet" "data" {
  count = var.create_vpc && var.create_data_subnets ? var.availability_zones_count : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = local.data_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name        = "${var.project_name}-${var.environment}-data-${local.azs[count.index]}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "data"
  }
}

#=============================================================================================
# ELASTIC IPs PARA NAT GATEWAY
#=============================================================================================
# IPs elásticos para os NAT Gateways (1 ou mais dependendo de nat_gateway_ha)
resource "aws_eip" "nat" {
  count = var.create_vpc && var.create_private_subnets ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_internet_gateway.this]
}

#=============================================================================================
# NAT GATEWAY
#=============================================================================================
# NAT Gateway para permitir acesso à internet das subnets privadas
# Quantidade: 1 total (econômico) ou 1 por AZ (alta disponibilidade)
resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.create_private_subnets ? local.nat_gateway_count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_internet_gateway.this]
}

#=============================================================================================
# ROUTE TABLE PÚBLICA
#=============================================================================================
# Tabela de rotas para subnets públicas (rota padrão via Internet Gateway)
resource "aws_route_table" "public" {
  count = var.create_vpc && var.create_public_subnets ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Associa subnets públicas à route table pública
resource "aws_route_table_association" "public" {
  count = var.create_vpc && var.create_public_subnets ? var.availability_zones_count : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

#=============================================================================================
# ROUTE TABLES PRIVADAS
#=============================================================================================
# Tabelas de rotas para subnets privadas (rota padrão via NAT Gateway)
# Quantidade: 1 total ou 1 por AZ (dependendo de nat_gateway_ha)
resource "aws_route_table" "private" {
  count = var.create_vpc && var.create_private_subnets ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Associa subnets privadas às route tables privadas
resource "aws_route_table_association" "private" {
  count = var.create_vpc && var.create_private_subnets ? var.availability_zones_count : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.nat_gateway_ha ? count.index : 0].id
}

#=============================================================================================
# ROUTE TABLE DATA
#=============================================================================================
# Tabela de rotas para subnets data (sem rota para internet)
resource "aws_route_table" "data" {
  count = var.create_vpc && var.create_data_subnets ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-data-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Associa subnets data à route table data
resource "aws_route_table_association" "data" {
  count = var.create_vpc && var.create_data_subnets ? var.availability_zones_count : 0

  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data[0].id
}
