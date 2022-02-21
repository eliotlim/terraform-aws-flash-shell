resource "aws_vpc" "example" {
  cidr_block = "192.168.0.0/24"

  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "flash-shell-example"
  })
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = merge(var.tags, {
    Name = "flash-shell-example"
  })
}

resource "aws_route" "example" {
  route_table_id         = aws_vpc.example.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
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
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = merge(var.tags, {
    Name = "flash-shell-example"
  })
}
