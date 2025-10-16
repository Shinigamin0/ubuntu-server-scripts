terraform fmt
terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
terraform output -json > moodle-develop.json