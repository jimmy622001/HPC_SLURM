variable "project_name" {
  description = "Name for this project"
  type        = string
}

variable "environment" {
  description = "Environment for deployment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of public subnets for load balancer"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "allowed_monitoring_cidr_blocks" {
  description = "CIDR blocks allowed to access monitoring dashboards"
  type        = list(string)
}

variable "head_node_private_ip" {
  description = "Private IP of the cluster head node"
  type        = string
}

variable "head_node_id" {
  description = "Instance ID of the head node"
  type        = string
}

variable "bastion_host" {
  description = "Bastion host public IP or DNS"
  type        = string
}

variable "ssh_key_path" {
  description = "Path to SSH private key for node access"
  type        = string
}

variable "bastion_user" {
  description = "Username for bastion host"
  type        = string
  default     = "ec2-user"
}

variable "bastion_private_key_path" {
  description = "Path to private key for bastion host"
  type        = string
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "dummy_certificate" {
  description = "Whether to use a self-signed dummy certificate for HTTPS"
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for HTTPS"
  type        = string
  default     = ""
}

variable "create_route53_record" {
  description = "Whether to create Route53 record"
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "Route53 zone ID"
  type        = string
  default     = ""
}

variable "dns_domain" {
  description = "DNS domain for Route53 record"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
variable "prometheus_port" {
  description = "Port for Prometheus service"
  type        = number
  default     = 9090
}