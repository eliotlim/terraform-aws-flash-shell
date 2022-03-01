module "sftp_client" {
  source  = "eliotlim/flash-shell/aws"
  version = "~>0.0.1"

  name               = var.name
  region             = var.region
  assign_public_ip   = true
  security_group_ids = [aws_security_group.client.id]
  subnet_ids         = [aws_subnet.public.id]

  environment = {
    SSH_KEYPAIR_SECRET_ID = aws_secretsmanager_secret.server.id
  }

  container_image_dockercontext = "${path.module}/docker"

  tags = merge(var.tags, {
    foo = "bar"
  })
}

data "aws_lambda_invocation" "sftp_client_invocation" {
  function_name = module.sftp_client.function_name
  input         = jsonencode({
    command = ["sftp", "-i", "./id_rsa", "-o", "StrictHostKeyChecking=no", "ec2-user@${aws_instance.server.private_ip}:/etc/hosts"]
  })

  depends_on = [
    module.sftp_client,
  ]
}

resource "aws_iam_role_policy_attachment" "sftp_server_access" {
  role       = module.sftp_client.task_role
  policy_arn = aws_iam_policy.server_access.arn
}
