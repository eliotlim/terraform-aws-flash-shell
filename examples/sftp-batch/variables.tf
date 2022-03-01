variable "name" {
  description = "Name of project / stack"
  type        = string
  default     = "sftp-batch"
}

variable "region" {
  description = "The region where AWS operations will take place."
  type        = string
  default     = "ap-southeast-1"
}

variable "tags" {
  description = "Tags for project resources"
  type        = map(string)
  default     = {
    Project   = "sftp-batch"
    Terraform = true
  }
}
