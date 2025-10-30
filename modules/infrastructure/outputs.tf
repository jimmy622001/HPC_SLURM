# Outputs for the infrastructure module

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.hpc_vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = var.enable_bastion_host ? aws_instance.bastion[0].public_ip : null
}

output "head_node_sg_id" {
  description = "Security group ID for the head node"
  value       = aws_security_group.head_node_sg.id
}

output "compute_node_sg_id" {
  description = "Security group ID for compute nodes"
  value       = aws_security_group.compute_node_sg.id
}

output "shared_storage_id" {
  description = "ID of the shared storage resource"
  value = var.enable_shared_storage ? (
    var.shared_storage_type == "efs" ? aws_efs_file_system.efs[0].id : aws_fsx_lustre_file_system.fsx[0].id
  ) : null
}

output "shared_storage_type" {
  description = "Type of shared storage deployed"
  value       = var.enable_shared_storage ? var.shared_storage_type : null
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = var.enable_shared_storage && var.shared_storage_type == "efs" ? aws_efs_file_system.efs[0].dns_name : null
}

output "fsx_lustre_dns_name" {
  description = "DNS name of the FSx Lustre file system"
  value       = var.enable_shared_storage && var.shared_storage_type == "fsx_lustre" ? aws_fsx_lustre_file_system.fsx[0].dns_name : null
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = var.enable_nat_gateway ? aws_nat_gateway.nat_gw[0].public_ip : null
}

output "enable_bastion_host" {
  description = "Whether bastion host is enabled"
  value       = var.enable_bastion_host
}

output "head_node_security_group_id" {
  description = "ID of the security group for the head node"
  value       = aws_security_group.head_node_sg.id
}

output "compute_node_security_group_id" {
  description = "ID of the security group for compute nodes"
  value       = aws_security_group.compute_node_sg.id
}

output "efs_id" {
  description = "ID of the EFS filesystem"
  value       = aws_efs_file_system.shared_storage.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = var.enable_bastion_host ? aws_security_group.bastion_sg[0].id : null
}