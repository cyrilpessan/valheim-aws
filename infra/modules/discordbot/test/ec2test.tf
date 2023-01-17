resource "aws_iam_role" "ec2test" {
  name = "ec2test"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2test" {
  role = aws_iam_role.ec2test.name
}

resource "aws_iam_policy" "ec2test" {
  name        = "ec2test"
  description = "ec2test temporary for testing purpose"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : ["ec2:DescribeInstances"],
        Resource : ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2test" {
  role       = aws_iam_role.ec2test.name
  policy_arn = aws_iam_policy.ec2test.arn
}

# data "aws_ami" "ec2test_ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"]
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-*"]
#   }
# }

resource "aws_security_group" "ec2test_ingress" {
  #checkov:skip=CKV2_AWS_5:Broken - https://github.com/bridgecrewio/checkov/issues/1203
  name        = "ec2test-ingress"
  description = "Security group allowing inbound traffic to the Valheim server"
}

resource "aws_security_group_rule" "ec2test_ssh_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  security_group_id = aws_security_group.ec2test_ingress.id
  description       = "Allows SSH"
}

resource "aws_spot_instance_request" "ec2test" {
  #checkov:skip=CKV_AWS_126:Detailed monitoring is an extra cost and unecessary for this implementation
  #checkov:skip=CKV_AWS_8:This is not a launch configuration
  #checkov:skip=CKV2_AWS_17:This instance will be placed in the default VPC deliberately
  ami           = "ami-0c0060c6b996c83e1"
  instance_type = "t3a.nano"
  ebs_optimized = true
  spot_type = "persistent"
  # user_data = templatefile("${path.module}/local/userdata.sh", {
  #   username = local.username
  #   bucket   = aws_s3_bucket.valheim.id
  # })
  iam_instance_profile           = aws_iam_instance_profile.ec2test.name
  vpc_security_group_ids         = [aws_security_group.ec2test_ingress.id]
  wait_for_fulfillment           = true
  instance_interruption_behavior = "stop"
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    name        = "valheim-dev-discordbot-test-server"
    description = "Instance running a Valheim server"
  }

  key_name = "cyril-dev"
}
