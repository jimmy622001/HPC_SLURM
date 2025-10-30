# Variables for the cluster module

variable "project_name" {
  description = "Name for this project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "head_node_sg_id" {
  description = "Security group ID for head node"
  type        = string
}

variable "compute_node_sg_id" {
  description = "Security group ID for compute nodes"
  type        = string
}

variable "shared_storage_id" {
  description = "ID of the shared storage resource"
  type        = string
}

variable "shared_storage_type" {
  description = "Type of shared storage (efs or fsx_lustre)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the SLURM cluster"
  type        = string
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

variable "max_queue_size" {
  description = "Maximum number of jobs in the queue"
  type        = number
  default     = 100
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

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use"
  type        = string
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

variable "enable_dashboard" {
  description = "Whether to deploy CloudWatch dashboard for monitoring"
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for cluster nodes"
  type        = string
  default     = ""
}