# Variables for the infrastructure module

variable "project_name" {
  description = "Name for this project"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_shared_storage" {
  description = "Whether to deploy shared storage (EFS or FSx for Lustre)"
  type        = bool
  default     = true
}

variable "shared_storage_type" {
  description = "Type of shared storage to deploy (efs or fsx_lustre)"
  type        = string
  default     = "efs"

  validation {
    condition     = contains(["efs", "fsx_lustre"], var.shared_storage_type)
    error_message = "Shared storage type must be either 'efs' or 'fsx_lustre'."
  }
}

variable "fsx_lustre_capacity" {
  description = "Storage capacity for FSx Lustre in GB"
  type        = number
  default     = 1200
}

variable "fsx_lustre_deployment_type" {
  description = "Deployment type for FSx Lustre"
  type        = string
  default     = "SCRATCH_2"

  validation {
    condition     = contains(["SCRATCH_1", "SCRATCH_2", "PERSISTENT_1", "PERSISTENT_2"], var.fsx_lustre_deployment_type)
    error_message = "FSx Lustre deployment type must be one of: SCRATCH_1, SCRATCH_2, PERSISTENT_1, PERSISTENT_2."
  }
}

