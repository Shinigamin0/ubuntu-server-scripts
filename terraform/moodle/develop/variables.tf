variable "ami" {
  description = "AMI ID for the Moodle EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "name" {
  description = "Project name prefix"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "nat_per_az" {
  description = "Enable NAT gateway per AZ"
  type        = bool
  default     = true
}
