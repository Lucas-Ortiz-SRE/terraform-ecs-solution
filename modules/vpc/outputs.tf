output "vpc_id" {
  value = var.create_vpc ? aws_vpc.this[0].id : null
}

output "vpc_cidr" {
  value = var.create_vpc ? aws_vpc.this[0].cidr_block : null
}

output "public_subnet_ids" {
  value = var.create_vpc && var.create_public_subnets ? aws_subnet.public[*].id : []
}

output "private_subnet_ids" {
  value = var.create_vpc && var.create_private_subnets ? aws_subnet.private[*].id : []
}

output "data_subnet_ids" {
  value = var.create_vpc && var.create_data_subnets ? aws_subnet.data[*].id : []
}

output "nat_gateway_ids" {
  value = var.create_vpc && var.create_private_subnets ? aws_nat_gateway.this[*].id : []
}

output "internet_gateway_id" {
  value = var.create_vpc && var.create_public_subnets ? aws_internet_gateway.this[0].id : null
}
