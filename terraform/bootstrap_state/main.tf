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

resource "aws_s3_bucket" "tf_state" {
  bucket        = var.state_bucket_name
  force_destroy = false

  tags = {
    Name    = var.state_bucket_name
    Purpose = "terraform-state"
    Owner   = "Shinigamin"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state_pab" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

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

resource "aws_s3_object" "state_prefix_production" {
  bucket = aws_s3_bucket.tf_state.bucket
  key    = "states/production/"
  acl    = "private"
}

resource "aws_s3_object" "state_prefix_develop" {
  bucket = aws_s3_bucket.tf_state.bucket
  key    = "states/develop/"
  acl    = "private"
}

resource "aws_s3_object" "state_prefix_quality" {
  bucket = aws_s3_bucket.tf_state.bucket
  key    = "states/quality/"
  acl    = "private"
}

