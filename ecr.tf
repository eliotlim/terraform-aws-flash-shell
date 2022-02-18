resource "aws_ecr_repository" "this" {
  count = var.container_image_url == null ? 1 : 0

  name                 = var.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
