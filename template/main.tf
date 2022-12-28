module "main" {
  source = "../module"

  admins           = var.admins
  aws_region       = var.aws_region
  domain           = var.domain
  instance_type    = var.instance_type
  keybase_username = var.keybase_username
  purpose          = var.purpose
  server_name      = var.server_name
  server_password  = var.server_password
  sns_email        = var.sns_email
  unique_id        = var.unique_id
  world_name       = var.world_name
  ec2_keypair_name = var.ec2_keypair_name
}

resource "aws_s3_object" "world_fwl" {
  count = var.initial_world_name != "" ? 1 : 0
  bucket         = module.main.bucket_id
  key            = "${var.initial_world_name}.fwl"
  source         = "./world/${var.initial_world_name}.fwl"
  etag           = filemd5("./world/${var.initial_world_name}.fwl")
}

resource "aws_s3_object" "world_db" {
  count = var.initial_world_name != "" ? 1 : 0
  bucket         = module.main.bucket_id
  key            = "${var.initial_world_name}.db"
  source         = "./world/${var.initial_world_name}.db"
  etag           = filemd5("./world/${var.initial_world_name}.db")
}

# output "monitoring_url" {
#   value       = module.main.monitoring_url
#   description = "URL to monitor the Valheim Server"
# }

output "bucket_id" {
  value       = module.main.bucket_id
  description = "The S3 bucket name"
}

output "instance_id" {
  value       = module.main.instance_id
  description = "The EC2 instance ID"
}

# output "valheim_user_passwords" {
#   value       = module.main.valheim_user_passwords
#   description = "List of AWS users and their encrypted passwords"
# }
