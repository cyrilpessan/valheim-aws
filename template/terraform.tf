terraform {
  required_version = ">= 1.3.6"

  backend "s3" {
    bucket = <name of your Valheim Management bucket>
    key    = "valheim-server/prod/terraform.tfstate"
    region = "eu-west-3"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~> 3.0"
      version = "~> 4.48"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
