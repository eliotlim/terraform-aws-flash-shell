data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = "AllowECSTaskAssumeRole"
    principals {
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "ecs.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "execution" {
  name                 = "${var.name}-execution"
  path                 = var.resource_path_prefix
  permissions_boundary = var.permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role" "this" {
  name                 = "${var.name}-task"
  path                 = var.resource_path_prefix
  permissions_boundary = var.permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "execute_ecs_task" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "this_ecs_task" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = "AllowLambdaAssumeRole"
    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "this_lambda" {
  name                 = var.name
  permissions_boundary = var.permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy" "lambda_vpc_access" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.this_lambda.name
  policy_arn = data.aws_iam_policy.lambda_vpc_access.arn
}

resource "aws_iam_role_policy_attachment" "lambda_ecs_invoke_task" {
  role       = aws_iam_role.this_lambda.name
  policy_arn = aws_iam_policy.lambda_invoke_ecs_task.arn
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_logs" {
  role       = aws_iam_role.this_lambda.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}

data "aws_iam_policy_document" "lambda_run_ecs" {
  statement {
    actions   = ["ecs:RunTask"]
    effect    = "Allow"
    sid       = "AllowECSRunTask"
    resources = [
      aws_ecs_task_definition.this.arn,
      replace(aws_ecs_task_definition.this.arn, "/^(?P<arn>.*):[0-9]+$/", "$arn")
    ]
  }
  statement {
    actions   = ["iam:PassRole"]
    effect    = "Allow"
    sid       = "AllowIAMPassRole"
    resources = [
      aws_iam_role.execution.arn,
      aws_iam_role.this.arn,
    ]
  }
}

resource "aws_iam_policy" "lambda_invoke_ecs_task" {
  name        = "${var.name}-invoke-ecs"
  path        = var.resource_path_prefix
  description = "IAM policy for invoking ECS task"

  policy = data.aws_iam_policy_document.lambda_run_ecs.json
}

data "aws_iam_policy_document" "lambda_log_append" {
  statement {
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect    = "Allow"
    sid       = "AllowLogGroupCreateAppend"
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_cloudwatch_logs" {
  name        = "${var.name}-append-logs"
  path        = var.resource_path_prefix
  description = "IAM policy for logging events to CloudWatch from Lambda"

  policy = data.aws_iam_policy_document.lambda_log_append.json
}
