terraform {
  required_version = ">= 1.5.0"
  backend "s3" {} # usa backend.hcl en terraform init
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ---------------- VPC ----------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr              # ej: "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "${var.name}-vpc" })
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

# ---------- SUBNETS ----------
# Mapear índices para usar for_each de forma estable
locals {
  idx_map = { for idx, az in var.azs : tostring(idx) => az }

  # Validaciones ligeras
  ok_public  = length(var.public_cidrs)  == length(var.azs)
  ok_private = length(var.private_cidrs) == length(var.azs)
}

# (Opcional) Validaciones “hard” que abortan si no coinciden
# Puedes mover estas a variables.tf si prefieres
locals {
  _check_public  = local.ok_public  ? 1 : tonumber("public_cidrs y azs deben tener la misma longitud")
  _check_private = local.ok_private ? 1 : tonumber("private_cidrs y azs deben tener la misma longitud")
}

# Subnets públicas (una por AZ)
resource "aws_subnet" "public" {
  for_each                = local.idx_map
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_cidrs[tonumber(each.key)]
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "${var.name}-public-${each.value}" })
}

# Subnets privadas (una por AZ)
resource "aws_subnet" "private" {
  for_each                = local.idx_map
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_cidrs[tonumber(each.key)]
  availability_zone       = each.value
  map_public_ip_on_launch = false
  tags = merge(var.tags, { Name = "${var.name}-private-${each.value}" })
}

# ---------- RUTAS PÚBLICAS (compartida) ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-rt-public" })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------- NAT (por AZ o único) ----------
# EIP(s) para NAT
resource "aws_eip" "nat_eip" {
  for_each = var.nat_per_az ? local.idx_map : { "0" = var.azs[0] }
  domain   = "vpc"
  tags     = merge(var.tags, { Name = "${var.name}-eip-nat-${each.value}" })
}

# NAT GW en cada pública (o solo en la primera)
resource "aws_nat_gateway" "nat" {
  for_each      = var.nat_per_az ? local.idx_map : { "0" = var.azs[0] }
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = var.nat_per_az ? aws_subnet.public[each.key].id : aws_subnet.public["0"].id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(var.tags, { Name = "${var.name}-nat-${each.value}" })
}

# ---------- RUTAS PRIVADAS ----------
# Si hay NAT por AZ → RT privada por AZ.
# Si hay 1 NAT → 1 RT privada compartida.
resource "aws_route_table" "private" {
  for_each = var.nat_per_az ? local.idx_map : { "0" = "shared" }
  vpc_id   = aws_vpc.this.id
  tags     = merge(var.tags, { Name = "${var.name}-rt-private-${each.value}" })
}

resource "aws_route" "private_default" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_per_az ? aws_nat_gateway.nat[each.key].id : aws_nat_gateway.nat["0"].id
}

# Asociar cada subnet privada a su RT:
# - NAT por AZ: RT[i] -> subnet privada i
# - 1 NAT: RT[0] -> todas las privadas
resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = var.nat_per_az ? aws_route_table.private[each.key].id : aws_route_table.private["0"].id
}

