variable "region" {
  type        = string
  description = "Región AWS"
  default     = "us-east-1"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a"]
}

variable "public_cidrs" {
  type        = list(string)
  description = "CIDRs para subnets públicas"
  default     = ["10.0.20.0/24"]
}

variable "private_cidrs" {
  type        = list(string)
  description = "CIDRs para subnets privadas"
  default     = ["10.0.30.0/24"]
}

variable "nat_per_az" {
  type        = bool
  description = "true = NAT por AZ, false = un solo NAT compartido"
  default     = true
}

variable "name" {
  type        = string
  description = "Nombre del ambiente"
  default     = "shinigamin-net-develop"
}

variable "tags" {
  type        = map(string)
  description = "Tags comunes"
  default = {
    Project = "shinigamin-stack-develop"
    Owner   = "Shinigamin"
  }
}

variable "vpc_cidr" {
  type        = string
  description = "El bloque CIDR para la VPC (ej: 10.0.0.0/16)"
  default     = "10.0.0.0/16"
}
