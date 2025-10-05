terraform {
  required_version = ">= 1.5.0"
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

# Bucket para estado remoto (sin DynamoDB)
resource "aws_s3_bucket" "tf_state" {
  bucket        = var.state_bucket_name
  force_destroy = false

  tags = {
    Name    = var.state_bucket_name
    Purpose = "terraform-state"
    Owner   = "infra"
  }
}

# Bloqueo de acceso público
resource "aws_s3_bucket_public_access_block" "tf_state_pab" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Versioning
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encripción por defecto (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Política para exigir TLS
data "aws_iam_policy_document" "tf_state_policy_doc" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "tf_state_policy" {
  bucket = aws_s3_bucket.tf_state.id
  policy = data.aws_iam_policy_document.tf_state_policy_doc.json
}

# Crear los "directorios" usados en el backend
resource "aws_s3_object" "state_prefix" {
  bucket = aws_s3_bucket.tf_state.bucket
  key    = "terraform/state/" # S3 trata esto como un "folder"
  acl    = "private"
}

output "state_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}
