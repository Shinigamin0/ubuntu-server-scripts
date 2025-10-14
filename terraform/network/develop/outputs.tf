output "public_subnet_ids" {
  description = "IDs de subnets públicas (orden por índice de var.azs)"
  value       = [for k in sort(keys(aws_subnet.public)) : aws_subnet.public[k].id]
}

output "private_subnet_ids" {
  description = "IDs de subnets privadas (orden por índice de var.azs)"
  value       = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].id]
}

output "nat_gateway_ids" {
  description = "IDs de NAT Gateways (1 por AZ si nat_per_az=true, 1 total si false)"
  value       = [for k in sort(keys(aws_nat_gateway.nat)) : aws_nat_gateway.nat[k].id]
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_ids" {
  value = [for k in sort(keys(aws_route_table.private)) : aws_route_table.private[k].id]
}

output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID de la VPC creada"
}

