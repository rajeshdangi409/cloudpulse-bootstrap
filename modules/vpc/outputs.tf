output "vpc_id" {
  description = "Bootstrap VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Bootstrap public subnet ID"
  value       = aws_subnet.public.id
}
