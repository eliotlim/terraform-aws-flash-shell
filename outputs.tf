output "family" {
  value = aws_ecs_task_definition.this.family
}

output "revision" {
  value = aws_ecs_task_definition.this.revision
}

output "arn" {
  value = aws_ecs_task_definition.this.arn
}

output "arn_family" {
  description = "Task Family ARN (without version qualifier)"
  value       = replace(aws_ecs_task_definition.this.arn, "/^(?P<arn>.*):[0-9]+$/", "$arn")
}

output "cluster_id" {
  description = "ID of the created ECS cluster"
  value       = var.ecs_cluster == null ? aws_ecs_cluster.this[0].id : var.ecs_cluster
}

output "cluster_arn" {
  description = "ARN of the created ECS cluster"
  value       = var.ecs_cluster == null ? aws_ecs_cluster.this[0].arn : var.ecs_cluster
}

output "name" {
  description = "Name of this flash shell instance"
  value       = var.name
}

output "function_arn" {
  description = "Lambda Function ARN"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Lambda Function Trigger Name"
  value       = aws_lambda_function.this.function_name
}

output "execution_role" {
  value = aws_iam_role.execution.name
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "task_role" {
  value = aws_iam_role.this.name
}

output "task_role_arn" {
  value = aws_iam_role.this.arn
}
