variable "assign_public_ip" {
  description = "Assign a Public IP when running this task"
  type        = bool
  default     = false
}

variable "container_image_url" {
  description = "URL of the Elastic Container Repository"
  type        = string
  default     = null
}

variable "container_image_dockerfile" {
  description = "Dockerfile contents to build a Container Image"
  type        = string
  default     = null
}

variable "cpu" {
  description = "vCPU units (divided by 1024)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of container instances"
  type        = number
  default     = 1
}

variable "ecs_cluster" {
  description = "ECS Cluster"
  type        = string
  default     = null
}

variable "environment" {
  description = "Map containing environment key / value pairs"
  type        = map(string)
  default     = {}
}

variable "log_stream_prefix" {
  description = "Log stream prefix"
  type        = string
  default     = "/flash/shell/"
}

variable "resource_path_prefix" {
  description = "Prefix for all resources with paths (e.g. IAM, CloudWatch Logs)"
  type        = string
  default     = "/flash/shell/"
}

variable "memory" {
  description = "memory units (MB)"
  type        = number
  default     = 1024
}

variable "name" {
  description = "Name of this flash shell instance"
  type        = string
}

variable "permissions_boundary" {
  description = "ARN of IAM Permissions Boundary"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "repository_url" {
  description = "Repository URL or <image>:<tag>"
  type        = string
  default     = null
}

variable "secrets" {
  description = "Map containing environment key / ARN (secret) pairs"
  type        = map(string)
  default     = {}
}

variable "security_group_ids" {
  description = "List of security groups to apply to the container"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnets to place the container"
  type        = list(string)
}

variable "tags" {
  description = "Tags for created resources"
  type        = map(string)
}
