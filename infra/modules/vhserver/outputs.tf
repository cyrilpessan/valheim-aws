output "instance_id" {
  value = aws_spot_instance_request.valheim.spot_instance_id
}

output "bucket_id" {
  value = aws_s3_bucket.valheim.id
}