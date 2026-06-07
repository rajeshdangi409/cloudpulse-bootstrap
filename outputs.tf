output "jenkins_public_ip" {
  description = "Jenkins server public IP — ansible/inventory.ini me daalo"
  value       = module.jenkins.jenkins_public_ip
}

output "ansible_public_ip" {
  description = "Ansible server public IP — SSH karke playbook chalao"
  value       = module.ansible.ansible_public_ip
}

output "bootstrap_vpc_id" {
  description = "Bootstrap VPC ID"
  value       = module.vpc.vpc_id
}
