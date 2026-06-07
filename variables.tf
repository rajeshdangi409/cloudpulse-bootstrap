variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name — used for tagging all resources"
  type        = string
  default     = "cloudpulse"
}

variable "environment" {
  description = "Environment name (used in default tags)"
  type        = string
  default     = "bootstrap"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access (create in AWS Console first)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins and Ansible servers"
  type        = string
  default     = "t2.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for bootstrap VPC — main infra VPC (10.0.0.0/16) should be reserved for main infra, so use a different range here"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for bootstrap public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "tf_state_bucket" {
  description = "S3 bucket holding Terraform remote state (must match backend.tf; used to scope the Jenkins IAM role)"
  type        = string
  default     = "cloudpulse-terraform-state"
}

variable "tf_lock_table" {
  description = "DynamoDB table for Terraform state locking (must match backend.tf; used to scope the Jenkins IAM role)"
  type        = string
  default     = "terraform-lock-table"
}
