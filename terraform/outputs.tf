output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_instance.app_server.public_ip}"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_instance.app_server.public_ip}:9090"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${aws_instance.app_server.public_ip}:3001"
}