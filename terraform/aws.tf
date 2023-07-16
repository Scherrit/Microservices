terraform {
  required_version = "> 1.5.0"

  backend "remote" {
    organization = "Esckays"
    workspaces {
      name = "Terraform"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
