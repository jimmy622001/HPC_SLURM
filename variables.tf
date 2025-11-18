# General project variables
variable "project_name" {
  description = "Name for this project"
  type        = string
}

variable "environment" {
  description = "Environment for deployment"
  type        = string
}

variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
}

# VPC and network variables
variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR ranges"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR ranges"
  type        = list(string)
}

variable "bastion_key_name" {
  description = "Name of the SSH key pair to use for bastion host (must exist in AWS)"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access (e.g., [\"YOUR_IP_ADDRESS/32\"])"
  type        = list(string)
}

variable "allowed_monitoring_cidr" {
  description = "CIDR blocks allowed for monitoring access (e.g., [\"YOUR_IP_ADDRESS/32\"])"
  type        = list(string)
}

# Cluster variables
variable "cluster_name" {
  description = "Name of the SLURM cluster"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for cluster nodes (must exist in AWS)"
  type        = string
}

variable "ssh_key_path" {
  description = "Path to SSH private key"
  type        = string
  sensitive   = true
}

variable "head_node_instance_type" {
  description = "Instance type for the head node"
  type        = string
}

variable "compute_instance_types" {
  description = "Instance types for compute nodes (ordered by preference)"
  type        = list(string)
}

variable "min_compute_nodes" {
  description = "Minimum number of compute nodes"
  type        = number
}

variable "max_compute_nodes" {
  description = "Maximum number of compute nodes"
  type        = number
}

variable "max_queue_size" {
  description = "Maximum number of jobs in the queue"
  type        = number
}

variable "enable_spot_instances" {
  description = "Whether to use spot instances for compute nodes"
  type        = bool
}

variable "shared_storage_type" {
  description = "Type of shared storage (efs or fsx_lustre)"
  type        = string
}

variable "placement_group" {
  description = "Whether to use placement group for improved networking"
  type        = bool
}

variable "enable_hyperthreading" {
  description = "Whether to enable hyperthreading on compute nodes"
  type        = bool
}

# Grafana variables
variable "grafana_admin_password" {
  description = "Password for Grafana admin user"
  type        = string
  sensitive   = true
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "owner" {
  description = "Owner of the resources, used for tagging"
  type        = string
}

variable "enable_dashboard" {
  description = "Whether to enable the dashboard feature"
  type        = bool
}

variable "enable_vpn_endpoint" {
  description = "Whether to enable VPN endpoint"
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
}

variable "enable_bastion_host" {
  description = "Whether to enable bastion host"
  type        = bool
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
}

variable "enable_shared_storage" {
  description = "Whether to enable shared storage"
  type        = bool
}

# FSx Lustre variables
variable "fsx_lustre_capacity" {
  description = "Storage capacity for FSx Lustre in GB"
  type        = number
}

variable "fsx_lustre_deployment_type" {
  description = "Deployment type for FSx Lustre"
  type        = string
}

# Prometheus variables
variable "prometheus_port" {
  description = "Port for Prometheus service"
  type        = number
}

# Route53 variables
variable "create_route53_record" {
  description = "Whether to create Route53 record"
  type        = bool
}

variable "route53_zone_id" {
  description = "Route53 zone ID"
  type        = string
}

variable "dns_domain" {
  description = "DNS domain for Route53 record"
  type        = string
}

variable "dummy_certificate" {
  description = "Whether to use a self-signed dummy certificate for HTTPS"
  type        = bool
}

variable "bastion_user" {
  description = "Username for bastion host"
  type        = string
}