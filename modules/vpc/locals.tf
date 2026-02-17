locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.availability_zones_count)

  # Cálculo de CIDRs para subnets
  public_subnet_cidrs  = [for i in range(var.availability_zones_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs = [for i in range(var.availability_zones_count) : cidrsubnet(var.vpc_cidr, 8, i + 10)]
  data_subnet_cidrs    = [for i in range(var.availability_zones_count) : cidrsubnet(var.vpc_cidr, 8, i + 20)]

  # Número de NAT Gateways
  nat_gateway_count = var.nat_gateway_ha ? var.availability_zones_count : 1
}
