module "flash_bash" {
  source = "../../"

  name               = "flash-bash"
  region             = var.region
  security_group_ids = [aws_security_group.flash_shell.id]
  subnet_ids         = [aws_subnet.example.id]

  container_image_dockerfile = data.local_file.flash_bash_dockerfile.content

  tags = merge(var.tags, {
    foo = "bar"
  })
}

data "local_file" "flash_bash_dockerfile" {
  filename = "${path.module}/Dockerfile"
}
