variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource tags"
  type        = string
  default     = "devops-aws-docker-app"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "app_image" {
  description = "Docker image for the Node.js app"
  type        = string
  default     = "YOUR_DOCKERHUB_USERNAME/monitoring-demo-app:latest"
}
