# Deploy Dockerized App to AWS EC2 using Terraform

This is a simple DevOps project where I deployed a Dockerized Node.js application with MySQL to an AWS EC2 instance using Terraform.
The dockerized image was referenced from the project repo of " https://github.com/PrabalPiya/docker-image-CI-CD "

The goal of this project is to understand how Terraform, AWS EC2, Docker, Docker Compose, and Docker Hub connect in a real deployment workflow.

## Tools Used

* Terraform
* AWS EC2
* AWS Security Group
* AWS CLI
* Docker
* Docker Compose
* Docker Hub
* Node.js
* MySQL
* Git/GitHub

## Architecture

```text
Developer pushes code
→ GitHub Actions builds Docker image
→ Docker image is pushed to Docker Hub
→ Terraform creates AWS EC2 instance
→ EC2 user_data installs Docker
→ Docker Compose runs app and MySQL containers
→ User accesses the app using EC2 public IP
```

## Folder Structure

```text
devops-aws-docker-deployment/
│
├── versions.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── user_data.sh.tpl
├── .gitignore
└── README.md
```

## How to Run

### 1. Configure AWS CLI

```bash
aws configure
aws sts get-caller-identity
```

### 2. Update Docker Image Name

In `variables.tf`, update:

```hcl
variable "app_image" {
  default = "YOUR_DOCKERHUB_USERNAME/devops-k8s-app:latest"
}
```

Replace it with your real Docker Hub image.

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Format and Validate

```bash
terraform fmt
terraform validate
```

### 5. Preview Infrastructure

```bash
terraform plan
```

### 6. Create Infrastructure

```bash
terraform apply
```

Type:

```text
yes
```

### 7. Get App URL

```bash
terraform output app_url
```

### 8. Test Application

```bash
curl http://<public-ip>
curl http://<public-ip>/health
curl http://<public-ip>/books
```

### 9. Destroy Infrastructure

```bash
terraform destroy
```

