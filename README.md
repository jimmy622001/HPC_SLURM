# HPC on AWS with SLURM - Proof of Concept Project

## Overview

This project provides a comprehensive proof of concept for deploying and managing High-Performance Computing (HPC) workloads on AWS using SLURM as the job scheduler. It demonstrates key capabilities required for HPC administration in cloud environments, including:

- Setting up SLURM clusters on AWS with AWS ParallelCluster
- Job scheduling and resource optimization
- Implementing cost-saving features (autoscaling, spot instances)
- Comprehensive monitoring with Prometheus and Grafana
- Sample HPC applications with job submission examples

## Project Structure

The project is organized into four main modules:

1. **Infrastructure Module**
   - VPC with public and private subnets
   - Bastion host for secure access
   - Security groups and network configurations
   - Shared storage options (EFS, FSx for Lustre)

2. **Cluster Module**
   - SLURM cluster deployment using AWS ParallelCluster
   - Head node and compute node configurations
   - Autoscaling based on job queue
   - Support for spot instances and EFA networking

3. **Sample Application Module**
   - Example MPI and OpenMP applications
   - Job submission scripts for different workloads
   - Setup scripts and documentation

4. **Monitoring Module**
   - Prometheus for metrics collection
   - Grafana dashboards for SLURM cluster monitoring
   - Job statistics and performance metrics
   - System resource utilization visualization

## Features

### SLURM Cluster Management
- Complete cluster lifecycle management with AWS ParallelCluster
- Job queues with different resource allocations
- Support for various instance types and architectures

### Cost Optimization
- Dynamic scaling based on workload
- Spot instance integration for compute nodes
- Scheduled scaling for recurring workloads
- Instance selection based on workload requirements

### Monitoring and Observability
- Real-time monitoring of cluster status and job queues
- Performance metrics and resource utilization
- Custom dashboards for SLURM statistics
- Alerts for critical conditions

### Sample Workloads
- MPI application examples
- OpenMP workload samples
- Hybrid MPI/OpenMP applications
- Job submission templates for various scenarios

## Requirements

- AWS Account
- Terraform >= 1.0.0
- AWS CLI configured with appropriate permissions
- SSH key for accessing cluster nodes

## Getting Started

See the [USAGE.md](USAGE.md) file for detailed instructions on how to deploy and use this project.