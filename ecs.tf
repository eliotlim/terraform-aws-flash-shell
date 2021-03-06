resource "aws_ecs_task_definition" "this" {
  family = var.name

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = var.container_image_url != null ? var.container_image_url : aws_ecr_repository.this[0].repository_url
      cpu       = var.cpu
      memory    = var.memory
      essential = true

      environment = [for k, v in var.environment : { name = k, value = v }]
      secrets     = [for k, v in var.secrets : { name = k, valueFrom = v }]

      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = var.log_stream_prefix
        }
      }
    },
  ])

  cpu    = var.cpu
  memory = var.memory

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.this.arn

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_ecs_cluster" "this" {
  count = var.ecs_cluster == null ? 1 : 0

  name = var.name

  capacity_providers = ["FARGATE"]

  tags = merge(var.tags, {
    Name = var.name
  })
}

data "local_file" "container_dockerfile" {
  count    = var.container_image_dockercontext != null ? 1 : 0
  filename = "${var.container_image_dockercontext}/Dockerfile"
}

resource "null_resource" "container_image" {
  count = var.container_image_dockercontext != null ? 1 : 0

  provisioner "local-exec" {
    command     = <<EOF
      docker build --tag "${var.name}:latest" . && \
      docker tag "${var.name}:latest" "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.name}:latest"
    EOF
    working_dir = "${var.container_image_dockercontext}/"
    environment = {
      AWS_REGION = var.region
    }
  }

  triggers = {
    redeployment = sha256(join(",", [
      jsonencode(data.local_file.container_dockerfile),
    ]))
  }

  depends_on = [data.local_file.container_dockerfile]
}

data "aws_caller_identity" "current" {}

resource "null_resource" "container_repository" {
  count = var.container_image_dockercontext != null ? 1 : 0

  provisioner "local-exec" {
    command     = <<EOF
      aws ecr get-login-password --region ${var.region} | \
        docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com && \
      docker push "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.name}:latest"
    EOF
    working_dir = "${local.out}/"
    environment = {
      AWS_REGION = var.region
    }
  }

  triggers = {
    redeployment = sha256(join(",", [
      jsonencode(data.local_file.container_dockerfile),
      jsonencode(null_resource.container_image),
    ]))
  }

  depends_on = [null_resource.container_image]
}
