terraform fmt
terraform init -reconfigure -backend-config=backend.hcl
terraform plan/apply/destroy \
  -var='azs=["us-east-1a","us-east-1b"]' \
  -var='public_cidrs=["10.0.0.0/24","10.0.1.0/24"]' \
  -var='private_cidrs=["10.0.10.0/24","10.0.11.0/24"]' \
  -var='nat_per_az=true' \
  -var='name="shinigamin-net"' \
  -var='tags={Project="shinigamin-stack",Owner="Shinigamin"}'
