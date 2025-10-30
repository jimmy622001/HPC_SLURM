# VPC and Infrastructure Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.infrastructure.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.infrastructure.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.infrastructure.private_subnet_ids
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = module.infrastructure.bastion_public_ip
}

# Cluster Outputs
output "cluster_name" {
  description = "Name of the SLURM cluster"
  value       = module.cluster.cluster_name
}

output "head_node_private_ip" {
  description = "Private IP address of the head node"
  value       = module.cluster.head_node_private_ip
}

# Note: head_node_id is not available in the cluster module

# Monitoring Outputs
output "monitoring_url" {
  description = "URL for the monitoring dashboard"
  value       = module.monitoring.grafana_url
}

output "prometheus_endpoint" {
  description = "Endpoint for Prometheus"
  value       = module.monitoring.prometheus_endpoint
}

output "grafana_admin_username" {
  description = "Admin username for Grafana"
  value       = module.monitoring.grafana_admin_username
}

output "grafana_admin_password" {
  description = "Admin password for Grafana (sensitive)"
  value       = module.monitoring.grafana_admin_password
  sensitive   = true
}

# Sample Application Outputs
# Note: These outputs are commented out as they don't exist in the module
# output "sample_app_ready" {
#   description = "Whether the sample applications are ready to use"
#   value       = module.sample_application.applications_ready
# }

# output "sample_app_help" {
#   description = "Help information for the sample applications"
#   value       = module.sample_application.help_message
# }