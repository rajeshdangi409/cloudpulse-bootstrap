# -------------------------------------------------------
# Common tags merged into every resource via the modules.
# Defined once here, passed down to each module as var.tags.
# -------------------------------------------------------
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "UmeshDangi"
    Repo        = "cloudpulse-bootstrap"
  }
}

# -------------------------------------------------------
# VPC Module — creates the bootstrap VPC (for Jenkins + Ansible)
# Completely separate from the main infra VPC (different CIDR)
# -------------------------------------------------------
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  subnet_cidr  = var.subnet_cidr
  tags         = local.common_tags
}

# -------------------------------------------------------
# Jenkins Module — creates the Jenkins EC2 instance
# -------------------------------------------------------
module "jenkins" {
  source          = "./modules/jenkins"
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.subnet_id
  key_name        = var.key_name
  instance_type   = var.instance_type
  project_name    = var.project_name
  tf_state_bucket = var.tf_state_bucket
  tf_lock_table   = var.tf_lock_table
  tags            = local.common_tags
}

# -------------------------------------------------------
# Ansible Module — creates the Ansible EC2 instance
# -------------------------------------------------------
module "ansible" {
  source        = "./modules/ansible"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.subnet_id
  key_name      = var.key_name
  instance_type = var.instance_type
  project_name  = var.project_name
  tags          = local.common_tags
}
