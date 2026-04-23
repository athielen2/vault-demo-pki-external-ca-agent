terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">=5.8.0"
    }
  }
}

provider "vault" {
  address = var.vault_addr
}

provider "aws" {
  region = var.region
}
