variable "vpc_id" {
  description = "VPC ID where Jenkins will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for Jenkins EC2"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins server"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "cloudpulse"
}

variable "tags" {
  description = "Common tags merged into every resource"
  type        = map(string)
  default     = {}
}

variable "tf_state_bucket" {
  description = "S3 bucket holding Terraform remote state (for scoped Jenkins IAM access)"
  type        = string
  default     = "cloudpulse-terraform-state"
}

variable "tf_lock_table" {
  description = "DynamoDB table used for Terraform state locking (for scoped Jenkins IAM access)"
  type        = string
  default     = "terraform-lock-table"
}
