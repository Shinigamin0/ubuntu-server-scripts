cd terraform/bootstrap_state
terraform fmt 
terraform init
terraform plan -var="region=us-east-1" -var="state_bucket_name=shinigamin-terraform-state-us-east-1"
terraform apply -auto-approve -var="region=us-east-1" -var="state_bucket_name=shinigamin-terraform-state-us-east-1"
