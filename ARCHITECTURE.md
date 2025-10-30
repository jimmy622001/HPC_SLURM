# HPC on AWS Architecture

This document provides a detailed technical overview of the HPC on AWS architecture.

## System Architecture

The system follows a modular design with four main components:

![HPC Architecture Diagram]

### Infrastructure Module

The infrastructure module creates the foundational AWS resources:

- **VPC**: A dedicated VPC with CIDR block matching the configured value
- **Subnets**:
  - Public subnets for public-facing services like monitoring dashboards
  - Private subnets for HPC cluster nodes
- **Security Groups**:
  - Head node security group
  - Compute node security group
  - Shared storage security group
  - Monitoring security group
- **Connectivity**:
  - AWS Systems Manager (SSM) for secure, bastion-free access
  - SSM endpoints in private subnets
  - No need for public-facing bastion hosts

### Cluster Module

The cluster module deploys the SLURM cluster using AWS ParallelCluster:

- **Head Node**:
  - SLURM controller and scheduler
  - NFS server for shared home directories
  - Configured with custom instance type
  - Located in a private subnet
- **Compute Nodes**:
  - Autoscaling based on job queue
  - Support for multiple instance types
  - Optional spot instance usage
  - Optional EFA networking support
  - Located in private subnets
- **Shared Storage**:
  - FSx for Lustre for high-performance file system
  - EFS for durable shared storage
- **Networking**:
  - Placement groups for compute nodes
  - Enhanced networking
  - Optional EFA support

### Sample Application Module

The sample application module provides example HPC applications:

- **MPI Applications**:
  - Hello world example
  - Benchmarking tools
- **OpenMP Applications**:
  - Multi-threaded example
  - Performance testing
- **Job Scripts**:
  - Example SLURM job submission scripts
  - Various resource configurations

### Monitoring Module

The monitoring module provides comprehensive observability:

- **Prometheus**:
  - Metrics collection from all nodes
  - SLURM-specific metrics via exporters
  - Running in ECS Fargate for reliability
  - Persistent storage via EFS
- **Grafana**:
  - Custom dashboards for SLURM metrics
  - Job queue and completion statistics
  - Node utilization and performance
  - Cost optimization insights
  - Accessible via ALB with HTTPS
- **Exporters**:
  - Node exporter for system metrics
  - SLURM exporter for job and queue metrics
  - Custom metrics for cost monitoring

## Network Flow

1. **User Access Flow**:
   - User connects to head node via AWS Systems Manager (SSM)
   - User submits jobs to SLURM queue

2. **Job Execution Flow**:
   - SLURM schedules jobs based on resource requirements
   - Compute nodes scale up if needed
   - Job runs on allocated nodes
   - Results stored on shared storage
   - Compute nodes scale down when idle

3. **Monitoring Flow**:
   - Exporters collect metrics from all nodes
   - Prometheus scrapes metrics at regular intervals
   - Grafana displays metrics in dashboards
   - Alerts trigger based on threshold violations

## Security Considerations

- **Network Security**:
  - Private subnets for compute resources
  - Security groups limit traffic flow
  - Secure access exclusively via AWS Systems Manager (SSM)
  - No SSH exposure to the internet

- **IAM Security**:
  - Least privilege permissions
  - Instance profiles with minimal access
  - Service roles for specific functions

- **Data Security**:
  - Encrypted storage at rest
  - Secure transport with TLS
  - Access controls for shared storage

- **Monitoring Security**:
  - HTTPS for dashboard access
  - Authentication for Grafana
  - Limited access to Prometheus endpoints

## Cost Optimization

- **Compute Optimization**:
  - Autoscaling based on workload
  - Spot instances for non-critical workloads
  - Multiple instance types to optimize cost/performance

- **Storage Optimization**:
  - Tiered storage approach
  - FSx for Lustre for performance-critical workloads
  - EFS for durable shared storage

- **Monitoring and Alerting**:
  - Resource utilization dashboards
  - Cost optimization insights
  - Alerts for inefficient resource usage

## Scalability

The architecture is designed to scale from small test clusters to large production workloads:

- **Horizontal Scaling**:
  - Configurable number of compute nodes
  - Multiple instance types and sizes
  - Queue-based autoscaling

- **Storage Scaling**:
  - FSx for Lustre can scale to hundreds of GB/s
  - Multiple storage options based on requirements

- **Network Scaling**:
  - EFA support for large-scale MPI workloads
  - Placement groups for low-latency communication

## Reliability

- **Head Node Reliability**:
  - Persistent instance with EBS volumes
  - Regular backups of configuration

- **Storage Reliability**:
  - Managed services (FSx, EFS) with high durability
  - Regular snapshots for data protection

- **Monitoring Reliability**:
  - Prometheus and Grafana on managed services (ECS Fargate)
  - Persistent storage for metrics
  - Redundant deployment across availability zones