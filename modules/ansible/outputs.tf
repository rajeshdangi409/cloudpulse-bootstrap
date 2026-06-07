output "ansible_public_ip" {
  description = "Public IP of Ansible server"
  value       = aws_instance.ansible.public_ip
}
