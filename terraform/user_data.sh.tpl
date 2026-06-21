#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

echo "===== USER DATA STARTED ====="

yum update -y

# Do NOT install curl here.
# Amazon Linux already has curl-minimal.
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

echo "===== CREATE APP DIRECTORY ====="
mkdir -p /opt/devops-app
cd /opt/devops-app

cat > docker-compose.yml <<EOF
services:
  app:
    image: ${app_image}
    container_name: devops-node-app
    ports:
      - "80:3000"
    environment:
      PORT: 3000
      DB_HOST: mysql
      DB_USER: root
      DB_PASSWORD: rootpassword
      DB_NAME: bookdb
      DB_PORT: 3306
    depends_on:
      mysql:
        condition: service_healthy
    restart: unless-stopped

  mysql:
    image: mysql:8.0
    container_name: devops-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: bookdb
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-prootpassword"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  mysql_data:
EOF

cat > init.sql <<EOF
CREATE DATABASE IF NOT EXISTS bookdb;

USE bookdb;

CREATE TABLE IF NOT EXISTS books (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(255) NOT NULL
);

INSERT INTO books (id, title, author)
VALUES
  (1, 'The Pragmatic Programmer', 'Andrew Hunt and David Thomas'),
  (2, 'Clean Code', 'Robert C. Martin'),
  (3, 'Docker Deep Dive', 'Nigel Poulton')
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  author = VALUES(author);
EOF

echo "===== START CONTAINERS ====="
/usr/bin/docker compose up -d

echo "===== RUNNING CONTAINERS ====="
/usr/bin/docker ps

echo "===== USER DATA FINISHED ====="