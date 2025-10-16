module "network" {
  source        = "../../network/develop"
  azs           = var.azs
  public_cidrs  = var.public_cidrs
  private_cidrs = var.private_cidrs
  nat_per_az    = var.nat_per_az
  name          = var.name
  tags          = var.tags
}

resource "tls_private_key" "moodle_develop_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "moodle_develop_ssh_key_pair" {
  key_name   = "moodle-develop-ssh-key"
  public_key = tls_private_key.moodle_develop_ssh_key.public_key_openssh
}

resource "aws_secretsmanager_secret" "moodle_develop_ssh_key_secret" {
  name        = "moodle-develop-private-key"
  description = "Clave privada SSH para la instancia de Moodle Develop"
}

resource "aws_secretsmanager_secret_version" "moodle_develop_ssh_key_version" {
  secret_id     = aws_secretsmanager_secret.moodle_develop_ssh_key_secret.id
  secret_string = tls_private_key.moodle_develop_ssh_key.private_key_pem
}

resource "aws_security_group" "moodle_develop_sg" {
  name        = "moodle_develop_sg"
  description = "Security group para Moodle Develop Server"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.30.0/24"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_iam_role" "moodle_develop_ec2_role" {
  name = "moodle-develop-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "moodle_develop_ssm_policy" {
  role       = aws_iam_role.moodle_develop_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "moodle_develop_instance_profile" {
  name = "moodle-develop-ec2-ssm-profile"
  role = aws_iam_role.moodle_develop_ec2_role.name
}

resource "aws_instance" "moodle_develop" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = module.network.private_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.moodle_develop_sg.id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.moodle_develop_ssh_key_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.moodle_develop_instance_profile.name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_size           = 100
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "${var.name}-moodle"
  })

  user_data = file("${path.module}/scripts/install-moodle.sh")
}
