variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  default     = "eu-west-1"
}

variable "project_id" {
  type        = string
  description = "Project identifier used for tags and naming"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the existing VPC"
}

variable "allowed_ip_range" {
  type        = list(string)
  description = "List of IP ranges allowed to access the infrastructure"
}

variable "public_instance_id" {
  type        = string
  description = "Instance ID of the public EC2 instance"
}

variable "private_instance_id" {
  type        = string
  description = "Instance ID of the private EC2 instance"
}