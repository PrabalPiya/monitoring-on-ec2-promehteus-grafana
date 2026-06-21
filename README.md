# Monitoring on AWS EC2 with Prometheus and Grafana

This is a simple DevOps monitoring project where a simple Node.js application is deployed to an AWS EC2 instance using Terraform and Docker Compose.

The application exposes a `/metrics` endpoint for Prometheus. Prometheus collects the metrics, and Grafana is used to visualize them in dashboards.

The goal of this project is to understand how monitoring fits into a DevOps workflow after an application is deployed.

---

## What This Project Demonstrates

* Creating AWS infrastructure using Terraform
* Deploying a Dockerized application on EC2
* Running multiple services using Docker Compose
* Exposing application metrics using Prometheus client
* Scraping metrics with Prometheus
* Visualizing metrics with Grafana
* Monitoring EC2/server metrics using Node Exporter
* Troubleshooting user data, Docker, and monitoring issues

---

## Tools Used

* AWS EC2
* Terraform
* Docker
* Docker Compose
* GitHub Actions
* Docker Hub
* Node.js
* Express.js
* prom-client
* Prometheus
* Grafana
* Node Exporter

---

## Architecture

```text
Developer pushes code to GitHub
→ GitHub Actions builds Docker image
→ Docker image is pushed to Docker Hub
→ Terraform creates AWS EC2 instance
→ EC2 user_data installs Docker and Docker Compose
→ Docker Compose runs app, Prometheus, Grafana, and Node Exporter
→ Prometheus scrapes metrics
→ Grafana displays dashboards
```

Simple architecture:

```text
AWS EC2 Instance
│
├── Node.js App
│   ├── /
│   ├── /health
│   └── /metrics
│
├── Prometheus
│   └── Scrapes app and node-exporter metrics
│
├── Grafana
│   └── Visualizes Prometheus metrics
│
└── Node Exporter
    └── Exposes EC2 server metrics
```

---

## Folder Structure

```text
devops-monitoring-terraform-ec2/
│
├── app/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
│
├── terraform/
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── user_data.sh.tpl
│   └── .gitignore
│
├── .github/
│   └── workflows/
│       └── docker-ci.yml
│
├── .gitignore
└── README.md
```

---

## Application Endpoints

| Endpoint   | Purpose                     |
| ---------- | --------------------------- |
| `/`        | Basic homepage              |
| `/health`  | Health check endpoint       |
| `/metrics` | Prometheus metrics endpoint |

---

## CI/CD Workflow

GitHub Actions is used to build and push the Docker image to Docker Hub.

Pipeline flow:

```text
Push code to GitHub
→ GitHub Actions starts
→ Docker image is built
→ Image is pushed to Docker Hub
→ EC2 pulls the image during deployment
```

Docker image format:

```text
<dockerhub-username>/monitoring-demo-app:latest
```

Required GitHub secrets:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

---

## Terraform Infrastructure

Terraform creates:

```text
EC2 instance
Security Group
User data startup script
```

The Security Group allows:

| Port | Purpose             |
| ---- | ------------------- |
| 80   | Node.js application |
| 9090 | Prometheus UI       |
| 3001 | Grafana UI          |

---

## How to Deploy

### 1. Configure AWS CLI

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

---

### 2. Update Docker Image Name

In `terraform/variables.tf`, update:

```hcl
variable "app_image" {
  default = "YOUR_DOCKERHUB_USERNAME/monitoring-demo-app:latest"
}
```

Replace it with your real Docker Hub image.

---

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

---

### 4. Format and Validate

```bash
terraform fmt
terraform validate
```

---

### 5. Preview Infrastructure

```bash
terraform plan
```

---

### 6. Create Infrastructure

```bash
terraform apply
```

Type:

```text
yes
```

---

### 7. View Outputs

```bash
terraform output
```

You will get:

```text
app_url
prometheus_url
grafana_url
```

---

## Access the Services

Application:

```text
http://<public-ip>
```

Prometheus:

```text
http://<public-ip>:9090
```

Grafana:

```text
http://<public-ip>:3001
```

Grafana login:

```text
Username: admin
Password: admin123
```

Prometheus data source URL in Grafana:

```text
http://prometheus:9090
```

Do not use `localhost:9090` inside Grafana because Grafana is running inside a Docker container.

---

## Useful Prometheus Queries

Check target status:

```promql
up
```

Check app status:

```promql
up{job="monitoring-demo-app"}
```

Total app requests:

```promql
demo_http_requests_total
```

Request rate:

```promql
rate(demo_http_requests_total[1m])
```

Requests by route:

```promql
sum by (route) (demo_http_requests_total)
```

Requests by status code:

```promql
sum by (status_code) (demo_http_requests_total)
```

App memory usage:

```promql
process_resident_memory_bytes
```

EC2 CPU usage:

```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
```

EC2 memory usage:

```promql
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

---

## Common Issues Faced

### Docker command not found

This can happen if Docker installation fails during EC2 user data execution.

Check:

```bash
sudo cat /var/log/user-data.log
```

---

### Curl package conflict on Amazon Linux

Amazon Linux may already include `curl-minimal`, so installing full `curl` can cause package conflicts.

The user data script avoids this by installing only Docker:

```bash
yum install -y docker
```

and using the existing curl binary:

```bash
/usr/bin/curl
```

---

### Prometheus target is DOWN

Possible causes:

```text
Wrong target name
App container is not running
/metrics endpoint is missing
Prometheus config is incorrect
```

Correct target inside Docker Compose:

```text
app:3000
```

---

### Grafana cannot connect to Prometheus

Wrong:

```text
http://localhost:9090
```

Correct:

```text
http://prometheus:9090
```

---

### Grafana or Prometheus does not open in browser

Check EC2 Security Group.

Required ports:

```text
9090 for Prometheus
3001 for Grafana
```

---

