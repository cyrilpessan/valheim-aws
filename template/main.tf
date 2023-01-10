# module "vhserver" {
#   source = "../modules/vhserver"

#   admins           = var.admins
#   aws_region       = var.aws_region
#   domain           = var.domain
#   instance_type    = var.instance_type
#   keybase_username = var.keybase_username
#   purpose          = var.purpose
#   server_name      = var.server_name
#   server_password  = var.server_password
#   sns_email        = var.sns_email
#   unique_id        = var.unique_id
#   world_name       = var.world_name
#   ec2_keypair_name = var.ec2_keypair_name
# }

# resource "aws_s3_object" "world_fwl" {
#   count          = var.initial_world_name != "" ? 1 : 0
#   bucket         = module.vhserver.bucket_id
#   key            = "${var.initial_world_name}.fwl"
#   source         = "./world/${var.initial_world_name}.fwl"
#   etag           = filemd5("./world/${var.initial_world_name}.fwl")
# }

# resource "aws_s3_object" "world_db" {
#   count          = var.initial_world_name != "" ? 1 : 0
#   bucket         = module.vhserver.bucket_id
#   key            = "${var.initial_world_name}.db"
#   source         = "./world/${var.initial_world_name}.db"
#   etag           = filemd5("./world/${var.initial_world_name}.db")
# }

## DO NOT USE
# output "valheim_user_passwords" {
#   value       = module.vhserver.valheim_user_passwords
#   description = "List of AWS users and their encrypted passwords"
# }

module "discordbot" {
  source = "../modules/discordbot"

  account_id              = var.account_id
  aws_region              = var.aws_region
  discord_public_key      = var.discord_public_key
  discord_auth_token      = var.discord_auth_token
  discord_application_id  = var.discord_application_id
  stage                   = var.stage
}