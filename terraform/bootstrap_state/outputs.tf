output "state_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

output "develop_state_path" {
  value = aws_s3_object.state_prefix_develop.key
}

output "quality_state_path" {
  value = aws_s3_object.state_prefix_quality.key
}

output "production_state_path" {
  value = aws_s3_object.state_prefix_production.key
}