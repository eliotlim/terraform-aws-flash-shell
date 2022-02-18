resource "aws_vpc" "example" {
  cidr_block = "192.168.0.0/24"

  tags = merge(var.tags, {
    Name = "flash-shell-example"
  })
}

resource "aws_subnet" "example" {
  vpc_id = aws_vpc.example.id

  cidr_block = "192.168.0.0/26"

  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "flash-shell-example"
  })
}

resource "aws_security_group" "flash_shell" {
  vpc_id = aws_vpc.example.id

  name = "flash-shell-example"

  egress {
    from_port = 0
    protocol  = ""
    to_port   = 0
  }

  tags = merge(var.tags, {
    Name = "flash-shell-example"
  })
}
