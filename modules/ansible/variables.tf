variable "vpc_id" {
  description = "VPC ID where Ansible will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for Ansible EC2"
  type        = string
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Ansible server"
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
