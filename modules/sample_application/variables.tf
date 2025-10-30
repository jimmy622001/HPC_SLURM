# Variables for the sample application module

variable "project_name" {
  description = "Name for this project"
  type        = string
}

variable "cluster_name" {
  description = "Name of the SLURM cluster"
  type        = string
}

variable "head_node_ip" {
  description = "Private IP of the cluster head node"
  type        = string
}

variable "head_node_id" {
  description = "Instance ID of the cluster head node for SSM access"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "shared_storage_mount" {
  description = "Mount point for shared storage on cluster nodes"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use"
  type        = string
}

variable "apps_s3_bucket" {
  description = "S3 bucket containing applications and configurations"
  type        = string
}
variable "enable_dashboard" {
  description = "Whether to enable the dashboard feature"
  type        = bool
  default     = true
}