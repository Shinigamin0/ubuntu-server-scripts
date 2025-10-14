bucket  = "shinigamin-terraform-state-us-east-1"   # el bucket creado en bootstrap_state
key     = "terraform/state/network.tfstate"        # ruta/prefijo dentro del bucket
region  = "us-east-1"
encrypt = true
