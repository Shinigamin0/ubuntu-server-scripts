terraform fmt
terraform init -reconfigure -backend-config=backend.hcl
terraform plan/apply/destroy \
  -var='azs=["us-east-1a"]' \
  -var='public_cidrs=["10.0.20.0/24"]' \
  -var='private_cidrs=["10.0.30.0/24"]' \
  -var='nat_per_az=true' \
  -var='name="shinigamin-net-develop"' \
  -var='tags={Project="shinigamin-stack-develop",Owner="Shinigamin"}'
