variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "cloudpulse"
}

variable "vpc_cidr" {
  description = "CIDR block for bootstrap VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for bootstrap public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "tags" {
  description = "Common tags merged into every resource"
  type        = map(string)
  default     = {}
}
