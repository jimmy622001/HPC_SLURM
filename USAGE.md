# HPC on AWS with SLURM - Usage Guide

This guide explains how to deploy and use the HPC on AWS project.

## Prerequisites

Before you begin, ensure you have:

- AWS account with appropriate permissions
- AWS CLI installed and configured
- Terraform >= 1.0.0 installed
- SSH key pair for accessing cluster nodes

## Deployment Steps

### 1. Configure the Project

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/hpc-on-aws.git
   cd hpc-on-aws
   ```

2. Create your terraform.tfvars file:
   ```bash
   cp terraform.tfvars terraform.tfvars
   ```

3. Edit the `terraform.tfvars` file to set your configuration values:
   - Set your AWS region
   - Configure the network CIDR ranges
   - Set your SSH key name
   - Configure cluster parameters
   - Set a secure Grafana admin password
   - Restrict SSH and monitoring access to your IP or network

### 2. Initialize and Apply Terraform

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Validate the configuration:
   ```bash
   terraform validate
   ```

3. Plan the deployment:
   ```bash
   terraform plan
   ```

4. Deploy the infrastructure:
   ```bash
   terraform apply
   ```

5. Note the outputs for accessing your cluster:
   - Bastion host IP
   - Head node IP
   - Grafana monitoring URL

### 3. Accessing the SLURM Cluster

1. SSH to the bastion host:
   ```bash
   ssh -i /path/to/your/key.pem ec2-user@$(terraform output -raw bastion_public_ip)
   ```

2. From the bastion, SSH to the head node:
   ```bash
   ssh -i ~/.ssh/id_rsa ec2-user@$(terraform output -raw head_node_ip)
   ```

3. Check the SLURM cluster status:
   ```bash
   sinfo                # View node status
   squeue               # View job queue
   scontrol show nodes  # View detailed node information
   ```

### 4. Running Sample Applications

1. Setup the sample applications:
   ```bash
   cd ~/sample_applications
   ./setup_applications.sh
   ```

2. Submit example jobs:
   ```bash
   # MPI job
   sbatch job_scripts/submit_mpi.sh
   
   # OpenMP job
   sbatch job_scripts/submit_openmp.sh
   
   # Hybrid job
   sbatch job_scripts/submit_hybrid.sh
   ```

3. Monitor your jobs:
   ```bash
   squeue -u $USER     # Check job status
   sacct               # View accounting information
   ```

### 5. Accessing Monitoring Dashboards

1. Open the Grafana URL from the terraform outputs:
   ```bash
   echo $(terraform output -raw monitoring_url)
   ```

2. Login with:
   - Username: `admin`
   - Password: the value you set in `terraform.tfvars`

3. Browse available dashboards:
   - SLURM Cluster Overview
   - Job Statistics
   - System Performance

### 6. Customizing the Environment

#### Adding Users

1. Create users on the head node:
   ```bash
   sudo adduser username
   sudo passwd username
   ```

2. Create home directories:
   ```bash
   sudo mkdir -p /home/username
   sudo chown username:username /home/username
   ```

#### Adding Shared Storage

The cluster comes with EFS or FSx for Lustre storage (based on your configuration). To mount additional storage:

1. Create the mount point:
   ```bash
   sudo mkdir -p /shared/data
   ```

2. Mount your storage:
   ```bash
   sudo mount -t nfs4 fs-xxxxxxxx.efs.us-west-2.amazonaws.com:/ /shared/data
   ```

3. Add to /etc/fstab for persistence:
   ```bash
   sudo bash -c 'echo "fs-xxxxxxxx.efs.us-west-2.amazonaws.com:/ /shared/data nfs4 defaults,_netdev 0 0" >> /etc/fstab'
   ```

#### Customizing SLURM Configuration

1. Edit the SLURM configuration:
   ```bash
   sudo nano /opt/slurm/etc/slurm.conf
   ```

2. Apply changes:
   ```bash
   sudo systemctl restart slurmctld
   ```

### 7. Destroying the Infrastructure

When you're done, destroy the infrastructure to avoid ongoing charges:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Unable to connect to the bastion host**
   - Check your security group settings in terraform.tfvars
   - Make sure your IP address hasn't changed

2. **Jobs stuck in pending state**
   - Check node availability with `sinfo`
   - Check if nodes are being provisioned (may take 5-10 minutes)
   - Review jobs requirements with `scontrol show job <jobid>`

3. **Monitoring dashboard unreachable**
   - Check if your IP is allowed in the security group
   - Wait a few minutes for the services to start up

### Getting Help

For additional troubleshooting:

1. Check CloudWatch logs for cluster issues
2. Check ECS service logs for monitoring issues
3. Use AWS ParallelCluster CLI for advanced troubleshooting:
   ```bash
   pcluster describe-cluster --region us-west-2 --cluster-name $(terraform output -raw cluster_name)
   ```