output "grafana_url" {
  description = "URL to access Grafana"
  value       = var.create_route53_record ? "https://grafana.${var.dns_domain}" : aws_lb.monitoring.dns_name
}

output "prometheus_endpoint" {
  description = "Endpoint for Prometheus"
  value       = "http://${aws_lb.monitoring.dns_name}:${var.prometheus_port}"
}

output "monitoring_security_group_id" {
  description = "ID of the security group for monitoring services"
  value       = aws_security_group.monitoring.id
}

output "monitoring_efs_id" {
  description = "ID of the EFS file system for monitoring data"
  value       = aws_efs_file_system.monitoring.id
}

output "grafana_admin_username" {
  description = "Admin username for Grafana"
  value       = "admin" # Hardcoded admin username as it's not configurable
}

output "grafana_admin_password" {
  description = "Admin password for Grafana"
  value       = var.grafana_admin_password
  sensitive   = true
}

output "monitoring_alb_dns_name" {
  description = "DNS name of the ALB for monitoring services"
  value       = aws_lb.monitoring.dns_name
}

output "monitoring_alb_zone_id" {
  description = "Zone ID of the ALB for monitoring services"
  value       = aws_lb.monitoring.zone_id
}