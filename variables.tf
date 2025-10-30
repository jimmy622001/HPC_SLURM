# General project variables
variable "project_name" {
  description = "Name for this project"
  type        = string
  default     = "hpc-slurm"
}

variable "environment" {
  description = "Environment for deployment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-west-2"
}

# VPC and network variables
variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR ranges"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR ranges"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

# No bastion host is used. All connectivity is via AWS Systems Manager (SSM)

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for direct SSH access to nodes if needed (e.g., [\"YOUR_IP_ADDRESS/32\"]) - Primarily for monitoring access"
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
  default     = "slurm-cluster"
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
  default     = "c5.xlarge"
}

variable "compute_instance_types" {
  description = "Instance types for compute nodes (ordered by preference)"
  type        = list(string)
  default     = ["c5.2xlarge", "c5.4xlarge", "c5.12xlarge"]
}

variable "min_compute_nodes" {
  description = "Minimum number of compute nodes"
  type        = number
  default     = 0
}

variable "max_compute_nodes" {
  description = "Maximum number of compute nodes"
  type        = number
  default     = 10
}

variable "enable_spot_instances" {
  description = "Whether to use spot instances for compute nodes"
  type        = bool
  default     = true
}

variable "shared_storage_type" {
  description = "Type of shared storage (efs or fsx_lustre)"
  type        = string
  default     = "efs"
}

variable "placement_group" {
  description = "Whether to use placement group for improved networking"
  type        = bool
  default     = true
}

variable "enable_hyperthreading" {
  description = "Whether to enable hyperthreading on compute nodes"
  type        = bool
  default     = true
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
  default     = {}
}
variable "owner" {
  description = "Owner of the resources, used for tagging"
  type        = string
  default     = "hpc-admin"
}
variable "enable_dashboard" {
  description = "Whether to enable the dashboard feature"
  type        = bool
  default     = true
}
variable "enable_vpn_endpoint" {
  description = "Whether to enable VPN endpoint"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
  default     = false
}

# Only SSM is used for node access - this variable is kept only for backward compatibility
variable "enable_bastion_host" {
  description = "[DEPRECATED] - All connectivity is now via SSM"
  type        = bool
  default     = false
}