module "flash_bash" {
  source  = "eliotlim/flash-shell/aws"
  version = "~>0.0.2"

  name               = var.name
  region             = var.region
  assign_public_ip   = true
  security_group_ids = [aws_security_group.flash_shell.id]
  subnet_ids         = [aws_subnet.example.id]

  container_image_dockercontext = "${path.module}/docker"

  tags = merge(var.tags, {
    foo = "bar"
  })
}

data "aws_lambda_invocation" "flash_hello_world" {
  function_name = module.flash_bash.function_name
  input         = jsonencode({
    command = ["echo", "hello world"]
  })

  depends_on = [
    module.flash_bash,
  ]
}
