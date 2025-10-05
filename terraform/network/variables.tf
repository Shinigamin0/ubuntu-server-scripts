variable "region" {
  type        = string
  description = "Región AWS"
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "Prefijo de nombres (tags/recursos)"
  default     = "net"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR de la VPC que se creará"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "AZs, ej: [\"us-east-1a\",\"us-east-1b\"]"
}

variable "public_cidrs" {
  type        = list(string)
  description = "CIDRs para subnets públicas (mismo tamaño que azs)"
}

variable "private_cidrs" {
  type        = list(string)
  description = "CIDRs para subnets privadas (mismo tamaño que azs)"
}

variable "nat_per_az" {
  type        = bool
  description = "true = NAT en cada AZ (HA). false = un NAT único (ahorro)"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags comunes"
  default     = {}
}

