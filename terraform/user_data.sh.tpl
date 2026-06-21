#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

echo "===== USER DATA STARTED ====="

yum update -y

# Do not install curl. Amazon Linux already has curl-minimal.
yum install -y docker

systemctl start docker
systemctl enable docker

echo "===== DOCKER VERSION ====="
/usr/bin/docker --version

echo "===== INSTALL DOCKER COMPOSE ====="
mkdir -p /usr/local/lib/docker/cli-plugins

/usr/bin/curl -SL https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

echo "===== COMPOSE VERSION ====="
/usr/bin/docker compose version

echo "===== CREATE PROJECT DIRECTORY ====="
mkdir -p /opt/monitoring-demo
cd /opt/monitoring-demo

echo "===== CREATE PROMETHEUS CONFIG ====="
mkdir -p monitoring

cat > monitoring/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "monitoring-demo-app"
    metrics_path: "/metrics"
    static_configs:
      - targets: ["app:3000"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "prometheus"
    static_configs:
      - targets: ["prometheus:9090"]
EOF

echo "===== CREATE DOCKER COMPOSE FILE ====="
cat > docker-compose.yml <<EOF
services:
  app:
    image: ${app_image}
    container_name: monitoring-demo-app
    ports:
      - "80:3000"
    environment:
      PORT: 3000
    restart: unless-stopped

  prometheus:
    image: prom/prometheus:latest
    container_name: monitoring-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    depends_on:
      - app
      - node-exporter
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: monitoring-grafana
    ports:
      - "3001:3000"
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: admin123
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: monitoring-node-exporter
    ports:
      - "9100:9100"
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
EOF

echo "===== START MONITORING STACK ====="
/usr/bin/docker compose up -d

echo "===== RUNNING CONTAINERS ====="
/usr/bin/docker ps

echo "===== USER DATA FINISHED ====="