# Outputs for the cluster module

output "head_node_private_ip" {
  description = "Private IP of the head node"
  value       = "DYNAMIC" # In a real setup, this would be fetched from the ParallelCluster API
}

output "shared_storage_mount" {
  description = "Mount point for shared storage on cluster nodes"
  value       = var.shared_storage_type == "efs" ? "/shared" : "/lustre"
}

output "apps_s3_bucket" {
  description = "S3 bucket containing applications and configurations"
  value       = aws_s3_bucket.cluster_bucket.id
}

output "dashboard_url" {
  description = "URL for the CloudWatch dashboard (if enabled)"
  value       = var.enable_dashboard ? "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.id}#dashboards:name=${aws_cloudwatch_dashboard.cluster_dashboard[0].dashboard_name}" : null
}

output "slurm_version" {
  description = "SLURM version deployed on the cluster"
  value       = "22.05.7" # This would be determined by the ParallelCluster version
}

output "cluster_config_url" {
  description = "URL to the ParallelCluster configuration"
  value       = "s3://${aws_s3_bucket.cluster_bucket.id}/parallelcluster.yaml"
}

output "cluster_name" {
  description = "Name of the SLURM cluster"
  value       = var.cluster_name
}

output "compute_node_count" {
  description = "Number of compute nodes in the cluster"
  value       = aws_autoscaling_group.compute_nodes.desired_capacity
}

output "cluster_dashboard" {
  description = "URL for the SLURM cluster dashboard"
  value       = "http://${aws_instance.head_node.private_ip}:8080"
}
output "head_node_id" {
  description = "ID of the head node"
  value       = aws_instance.head_node.id
}