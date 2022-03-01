data "aws_ami" "server" {
  most_recent = true

  owners     = ["amazon"]
  name_regex = "amzn2-ami-hvm*"

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "server" {
  instance_type = "t2.micro"

  key_name = aws_key_pair.server.key_name

  ami = data.aws_ami.server.id

  root_block_device {
    volume_size           = 20
    delete_on_termination = true
  }

  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.server.id]

  user_data = file("${path.module}/userdata.sh")

  tags = merge(var.tags, {
    Name = "${var.name}-server"
  })
}

resource "aws_secretsmanager_secret" "server" {
  name = "${var.name}-keypair"
}

resource "aws_secretsmanager_secret_version" "server" {
  secret_id     = aws_secretsmanager_secret.server.id
  secret_string = tls_private_key.server.private_key_pem
}

resource "aws_key_pair" "server" {
  key_name   = var.name
  public_key = tls_private_key.server.public_key_openssh
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
}

resource "aws_iam_policy" "server_access" {
  name   = "${var.name}-keypair-access"
  policy = data.aws_iam_policy_document.server_access.json
}

data "aws_iam_policy_document" "server_access" {
  statement {
    effect  = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      aws_secretsmanager_secret.server.arn,
    ]
  }
}
