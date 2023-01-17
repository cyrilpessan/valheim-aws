terraform {
  required_version = ">= 1.3.6"

  # S3 configuration to be setup in the 'config' folder (sensitive)
  backend "s3" {}
}
