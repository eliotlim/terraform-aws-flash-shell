resource "aws_lambda_function" "this" {
  function_name = var.name
  role          = aws_iam_role.this_lambda.arn

  filename         = data.archive_file.lambda_deployment_package.output_path
  source_code_hash = data.archive_file.lambda_deployment_package.output_base64sha256
  handler          = "handler.handler"

  runtime = "python3.9"

  timeout = 5

  environment {
    variables = merge(var.environment, {
      TASK_DEFINITION          = aws_ecs_task_definition.this.family
      TASK_COUNT               = var.desired_count
      LAUNCH_TYPE              = "FARGATE"
      CLUSTER                  = var.ecs_cluster != null ? var.ecs_cluster : aws_ecs_cluster.this[0].id
      CONTAINER_NAME           = var.name
      NETWORK_ASSIGN_PUBLIC_IP = var.assign_public_ip ? "ENABLED" : "DISABLED"
      NETWORK_SECURITY_GROUPS  = join(" ", var.security_group_ids)
      NETWORK_SUBNETS          = join(" ", var.subnet_ids)
    })
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_vpc_access,
    aws_iam_role_policy_attachment.lambda_ecs_invoke_task,
    aws_cloudwatch_log_group.lambda,
  ]

  tags = merge(var.tags, {
    Name = var.name
  })
}

data "archive_file" "lambda_deployment_package" {
  type             = "zip"
  source_file      = "${path.module}/handler.py"
  output_file_mode = "0666"
  output_path      = "${local.out}/handler.zip"
}
