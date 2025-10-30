
# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
terraform {
  required_version = ">= 1.0.0"
}

# Define common tags as locals
locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
    Owner       = var.owner
  }
}
# Generate a random ID for unique resource naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Infrastructure Module - VPC, Subnets, Security Groups
module "infrastructure" {
  source = "./modules/infrastructure"

  project_name         = var.project_name
  availability_zones   = var.availability_zones
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

}
# SLURM Cluster Module
module "cluster" {
  source       = "./modules/cluster"
  project_name = var.project_name

  # Required arguments
  cluster_name           = var.cluster_name
  head_node_sg_id        = module.infrastructure.head_node_security_group_id
  compute_node_sg_id     = module.infrastructure.compute_node_security_group_id
  ssh_key_name           = var.ssh_key_name
  shared_storage_id      = module.infrastructure.efs_id
  shared_storage_type    = "efs"
  vpc_id                 = module.infrastructure.vpc_id
  private_subnet_ids     = module.infrastructure.private_subnet_ids
  compute_instance_types = var.compute_instance_types
  min_compute_nodes      = var.min_compute_nodes
  max_compute_nodes      = var.max_compute_nodes
  enable_spot_instances  = var.enable_spot_instances
  enable_dashboard       = var.enable_dashboard

  # Add SSM instance profile for cluster nodes
  iam_instance_profile = module.infrastructure.ssm_instance_profile_name
}

# Sample Application Module
module "sample_application" {
  source = "./modules/sample_application"

  # Required arguments
  project_name         = var.project_name
  cluster_name         = module.cluster.cluster_name
  head_node_ip         = module.cluster.head_node_private_ip
  head_node_id         = module.cluster.head_node_id
  aws_region           = var.aws_region
  shared_storage_mount = module.cluster.shared_storage_mount
  ssh_key_name         = var.ssh_key_name
  apps_s3_bucket       = module.cluster.apps_s3_bucket
}

# Monitoring Module - Prometheus and Grafana
module "monitoring" {
  source = "./modules/monitoring"

  # Required arguments
  project_name                   = var.project_name
  environment                    = var.environment
  region                         = var.aws_region
  vpc_id                         = module.infrastructure.vpc_id
  private_subnet_ids             = module.infrastructure.private_subnet_ids
  public_subnet_ids              = module.infrastructure.public_subnet_ids
  private_subnet_cidr_blocks     = var.private_subnet_cidrs
  allowed_monitoring_cidr_blocks = var.allowed_monitoring_cidr
  head_node_private_ip           = module.cluster.head_node_private_ip
  head_node_id                   = module.cluster.head_node_id

  # Grafana configuration
  grafana_admin_password = var.grafana_admin_password

  # Tags
  tags = local.tags
}
