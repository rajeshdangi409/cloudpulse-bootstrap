data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ansible" {
  name   = "${var.project_name}-ansible-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-ansible-sg" })
}

resource "aws_instance" "ansible" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ansible.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  # Ansible + Git are installed automatically at boot
  user_data = <<-EOF
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y git ansible-core
    mkdir -p /home/ec2-user/cloudpulse
    chown -R ec2-user:ec2-user /home/ec2-user/cloudpulse
    echo "Ansible server ready!" >> /var/log/ansible-setup.log
  EOF

  tags = merge(var.tags, { Name = "${var.project_name}-ansible-server" })
}
