ami           = "ami-020cba7c55df1f615"
instance_type = "t3.micro"
name          = "moodle-develop"
key_name      = "moodle-develop-ssh-key"

azs           = ["us-east-1a"]
public_cidrs  = ["10.0.20.0/24"]
private_cidrs = ["10.0.30.0/24"]
nat_per_az    = true

tags = {
  Project = "shinigamin-stack-develop"
  Owner   = "Shinigamin"
}
