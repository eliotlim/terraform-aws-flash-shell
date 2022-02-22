terraform {
  required_providers {
    aws = "~>3.74.0"
  }
}

provider "aws" {
  region = var.region
}
