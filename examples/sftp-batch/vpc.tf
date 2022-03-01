resource "aws_vpc" "example" {
  cidr_block = "192.168.0.0/24"

  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route" "example" {
  route_table_id         = aws_vpc.example.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.example.id

  cidr_block = "192.168.0.0/26"

  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.example.id

  cidr_block = "192.168.0.64/26"

  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_security_group" "client" {
  vpc_id = aws_vpc.example.id

  name = "${var.name}-client"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Access AWS APIs"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Access ${var.name} server"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-client"
  })
}

resource "aws_security_group" "server" {
  vpc_id = aws_vpc.example.id

  name = "${var.name}-server"

  ingress {
    security_groups = [aws_security_group.client.id]
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    description     = "Allow SFTP from ${var.name}-client"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-server"
  })
}
