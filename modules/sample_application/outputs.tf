# Outputs for the sample application module

output "app_bucket" {
  description = "S3 bucket containing the sample applications"
  value       = aws_s3_bucket.app_bucket.id
}

output "readme_url" {
  description = "URL to the README file with usage instructions"
  value       = "s3://${aws_s3_bucket.app_bucket.id}/README.md"
}


output "sample_application_ready" {
  description = "Status message for sample application"
  value       = "Sample MPI application ready for deployment" # Direct value instead of module reference
}

output "sample_application_help" {
  description = "Help message for sample application"
  value       = "Use 'sbatch /path/to/job_script.sh' to submit jobs" # Direct value
}