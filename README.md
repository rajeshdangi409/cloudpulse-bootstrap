# CloudPulse — Bootstrap Infrastructure

> **Repo 1 of 3** — Run this **FIRST**. Creates the Jenkins + Ansible servers that power the rest of the project.

This Terraform repository provisions the **foundational infrastructure** for the CloudPulse DevOps project: a dedicated VPC with two EC2 servers — one for **Jenkins** (CI/CD) and one for **Ansible** (configuration management).

---

## Why "Bootstrap"?

A classic DevOps chicken-and-egg problem: *Jenkins needs infrastructure to run, but we want Terraform/Jenkins to manage our infrastructure.*

We solve it in 3 phases:

```
Phase 1 → cloudpulse-bootstrap (this repo)   → Creates Jenkins + Ansible EC2   [run locally, once]
Phase 2 → cloudpulse-ansible                 → Configures Jenkins via Ansible  [run from Ansible server]
Phase 3 → cloudpulse-infra                   → Creates EKS/VPC/ECR via Jenkins [fully automated]
```

This repo is **Phase 1** — the only part you run manually from your laptop.

---

## What It Creates

| Resource | Details |
|----------|---------|
| **Bootstrap VPC** | `10.10.0.0/16` — fully isolated from the main infra VPC (`10.0.0.0/16`) |
| **Public Subnet** | `10.10.1.0/24` with Internet Gateway + route table |
| **Jenkins EC2** | `t2.micro`, Security Group (ports 22, 8080), **IAM Role with a scoped least-privilege policy** (EC2/EKS/ECR/ELB/AutoScaling + Terraform-state S3/DynamoDB — not AdministratorAccess) |
| **Ansible EC2** | `t2.micro`, Security Group (port 22), Ansible pre-installed via `user_data` |

> The Jenkins IAM Role means **no AWS keys are stored in Jenkins** — it authenticates to AWS automatically via the instance profile.

---

## Repository Structure

```
cloudpulse-bootstrap/
├── backend.tf                 # S3 remote state + DynamoDB lock + provider versions
├── providers.tf               # AWS provider config
├── main.tf                    # Wires the 3 modules together
├── variables.tf               # All input variables (parameterized)
├── outputs.tf                 # Jenkins IP, Ansible IP, VPC ID
├── terraform.tfvars.example   # Copy → terraform.tfvars and fill in
└── modules/
    ├── vpc/                   # Bootstrap VPC, subnet, IGW, route table
    ├── jenkins/              # Jenkins EC2 + Security Group + IAM Role
    └── ansible/             # Ansible EC2 + Security Group + user_data
```

---

## Prerequisites

Before running this repo, set up these **one-time** AWS resources:

1. **AWS CLI configured** with an admin IAM user
   ```bash
   aws configure
   aws sts get-caller-identity   # verify
   ```

2. **EC2 Key Pair** named `cloudpulse-key`
   - AWS Console → EC2 → Key Pairs → Create → download `.pem`
   - Store it: `C:\Users\<you>\.ssh\cloudpulse-key.pem` (Windows) or `~/.ssh/cloudpulse-key.pem`
   - `chmod 400` the file

3. **S3 bucket** for remote state (with a `bootstrap/` key prefix)
   ```bash
   aws s3 mb s3://cloudpulse-terraform-state --region ap-south-1
   ```

4. **DynamoDB table** for state locking
   - Table name: `terraform-lock-table`
   - Partition key: `LockID` (String)

---

## Usage

```bash
# 1. Configure your variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — at minimum set key_name = "cloudpulse-key"

# 2. Deploy
terraform init
terraform plan
terraform apply
```

After apply, Terraform prints the outputs you need next:

```
Outputs:
ansible_public_ip = "13.235.xx.xx"   ← SSH here to run Ansible (Phase 2)
jenkins_public_ip = "13.235.yy.yy"   ← Jenkins UI: http://<this-ip>:8080
bootstrap_vpc_id  = "vpc-0abc..."
```

---

## Input Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `ap-south-1` | AWS region |
| `project_name` | `cloudpulse` | Used for naming + tagging resources |
| `key_name` | *(required)* | EC2 Key Pair name for SSH |
| `instance_type` | `t2.micro` | EC2 type for both servers (free-tier) |
| `vpc_cidr` | `10.10.0.0/16` | Bootstrap VPC CIDR (kept separate from infra) |
| `subnet_cidr` | `10.10.1.0/24` | Public subnet CIDR |
| `tf_state_bucket` | `cloudpulse-terraform-state` | Terraform state S3 bucket (scopes the Jenkins IAM role) |
| `tf_lock_table` | `terraform-lock-table` | Terraform lock DynamoDB table (scopes the Jenkins IAM role) |

All values are parameterized — override any of them in `terraform.tfvars` without touching code.

---

## Outputs

| Output | Used For |
|--------|----------|
| `jenkins_public_ip` | Jenkins UI access + Ansible inventory target |
| `ansible_public_ip` | SSH target to run the Ansible playbook (Phase 2) |
| `bootstrap_vpc_id` | Reference / verification |

---

## Next Step

Once both servers are up, proceed to **Phase 2**:

➡️ **[cloudpulse-ansible](https://github.com/rajeshdangi409/cloudpulse-ansible)** — SSH into the Ansible server and run the playbook to configure Jenkins.

---

## Cleanup

```bash
terraform destroy
```

> ⚠️ Run `cloudpulse-infra` destroy **first** (EKS/VPC), then destroy this bootstrap repo. The two t2.micro servers are free-tier, but don't leave them running indefinitely.

---

## Design Decision: Custom Modules vs Registry Modules

A fair question: *why hand-write the VPC/EC2 modules instead of using the official Terraform Registry modules (e.g. `terraform-aws-modules/vpc/aws`)?*

| Approach | Pros | Cons |
|----------|------|------|
| **Registry module** (official) | Battle-tested, feature-rich, less code to write | Huge surface area, many inputs/outputs, harder to explain line-by-line |
| **Custom module** (this repo) | Small, only the resources we actually use, fully understandable | Fewer features, we maintain it ourselves |

**Decision for this project: custom modules.**

The goal here is an **explainable** portfolio/learning project — every resource should be something I can walk through and justify in an interview. The official registry modules are excellent for large production teams, but they add a lot of configuration and abstraction that isn't needed for two simple EC2 servers. By writing the modules myself, the code stays minimal and I understand exactly what each line does.

> **Interview note:** In a real production environment with a larger team, I would lean toward the well-maintained registry modules to avoid reinventing the wheel. For this scoped project, custom modules give better clarity and full control.

---

## State & Locking

- **Remote state:** stored in S3 (`cloudpulse-terraform-state/bootstrap/terraform.tfstate`)
- **State locking:** DynamoDB (`terraform-lock-table`) prevents concurrent `apply` corruption
- **Encryption:** state is encrypted at rest (`encrypt = true`)
