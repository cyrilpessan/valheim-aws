terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }

    time = {
      source = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }
}
