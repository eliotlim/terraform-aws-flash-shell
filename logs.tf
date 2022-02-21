resource "aws_cloudwatch_log_group" "lambda" {
  name = "${var.resource_path_prefix}${var.name}/lambda"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "${var.resource_path_prefix}${var.name}/ecs"
}
