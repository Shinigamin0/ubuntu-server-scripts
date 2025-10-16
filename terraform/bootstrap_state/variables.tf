variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region del bucket."
}

variable "state_bucket_name" {
  type        = string
  description = "Nombre del bucket S3 para el estado (único global)."
}
