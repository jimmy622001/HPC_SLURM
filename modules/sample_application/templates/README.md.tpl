# Sample HPC Applications for ${cluster_name}

This directory contains sample applications that demonstrate how to use the SLURM cluster for different types of HPC workloads.

## Available Applications

1. **MPI Hello World** - A simple MPI application demonstrating distributed computing
2. **OpenMP Example** - A shared memory parallel application using OpenMP
3. **Hybrid Example** - Demonstrates how to combine MPI and OpenMP for hierarchical parallelism

## Setup Instructions

1. SSH to the head node:
   ```bash
   ssh ec2-user@${head_node_ip}
   ```

2. Download and run the setup script:
   ```bash
   mkdir -p ~/setup
   aws s3 cp s3://${app_bucket}/setup/setup_applications.sh ~/setup/
   chmod +x ~/setup/setup_applications.sh
   ~/setup/setup_applications.sh ${app_bucket}
   ```

## Running Applications

### MPI Hello World

1. Submit the job:
   ```bash
   sbatch ~/job_scripts/submit_mpi.sh
   ```

2. Check job status:
   ```bash
   squeue
   ```

3. View job output (after completion):
   ```bash
   cat mpi_hello_world_*.out
   ```

### OpenMP Example

1. Submit the job:
   ```bash
   sbatch ~/job_scripts/submit_openmp.sh
   ```

2. Check job status:
   ```bash
   squeue
   ```

3. View job output (after completion):
   ```bash
   cat openmp_example_*.out
   ```

### Hybrid Example

1. Submit the job:
   ```bash
   sbatch ~/job_scripts/submit_hybrid.sh
   ```

2. Check job status:
   ```bash
   squeue
   ```

3. View job output (after completion):
   ```bash
   cat hybrid_example_*.out
   ```

## Using Shared Storage

All nodes have access to shared storage at `${shared_storage_mount}`. This is ideal for:

- Input data that needs to be accessed by all nodes
- Output files from your jobs
- Shared application binaries

Example usage:
```bash
# Create a directory for your job data
mkdir -p ${shared_storage_mount}/job_data

# Copy input files to shared storage
cp input_file.dat ${shared_storage_mount}/job_data/

# Add output path to your job script
#SBATCH --output=${shared_storage_mount}/job_data/results_%j.out
```

## Additional Resources

- AWS ParallelCluster documentation: https://docs.aws.amazon.com/parallelcluster/
- SLURM documentation: https://slurm.schedmd.com/documentation.html
- MPI Forum: https://www.mpi-forum.org/
- OpenMP: https://www.openmp.org/