#!/bin/bash
# Script to set up sample HPC applications on the SLURM cluster

# Check if S3 bucket parameter is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <s3-bucket-name>"
    exit 1
fi

S3_BUCKET=$1

# Set up working directories
echo "Setting up application directories..."
mkdir -p ~/apps/mpi_hello_world
mkdir -p ~/apps/openmp_example
mkdir -p ~/job_scripts

# Download MPI Hello World application
echo "Downloading and building MPI Hello World application..."
aws s3 cp s3://$S3_BUCKET/applications/mpi_hello_world/mpi_hello_world.c ~/apps/mpi_hello_world/
aws s3 cp s3://$S3_BUCKET/applications/mpi_hello_world/Makefile ~/apps/mpi_hello_world/

# Download OpenMP example application
echo "Downloading and building OpenMP example application..."
aws s3 cp s3://$S3_BUCKET/applications/openmp_example/openmp_example.c ~/apps/openmp_example/
aws s3 cp s3://$S3_BUCKET/applications/openmp_example/Makefile ~/apps/openmp_example/

# Download job scripts
echo "Downloading job submission scripts..."
aws s3 cp s3://$S3_BUCKET/job_scripts/submit_mpi.sh ~/job_scripts/
aws s3 cp s3://$S3_BUCKET/job_scripts/submit_openmp.sh ~/job_scripts/
aws s3 cp s3://$S3_BUCKET/job_scripts/submit_hybrid.sh ~/job_scripts/

# Make job scripts executable
chmod +x ~/job_scripts/*.sh

# Load modules and build applications
echo "Loading modules and building applications..."

# Check for Intel MPI (AWS ParallelCluster default)
if command -v module &> /dev/null; then
    module load openmpi
    echo "Loaded OpenMPI module"
else
    echo "Module command not available. Assuming MPI is already in PATH."
fi

# Build MPI application
echo "Building MPI application..."
cd ~/apps/mpi_hello_world
make
if [ $? -ne 0 ]; then
    echo "Error building MPI application"
    exit 1
fi

# Build OpenMP application
echo "Building OpenMP application..."
cd ~/apps/openmp_example
make
if [ $? -ne 0 ]; then
    echo "Error building OpenMP application"
    exit 1
fi

echo "Applications have been set up successfully!"
echo ""
echo "To run the MPI application:"
echo "  sbatch ~/job_scripts/submit_mpi.sh"
echo ""
echo "To run the OpenMP application:"
echo "  sbatch ~/job_scripts/submit_openmp.sh"
echo ""
echo "To run the hybrid example:"
echo "  sbatch ~/job_scripts/submit_hybrid.sh"
echo ""
echo "To check job status:"
echo "  squeue"
echo ""
echo "To check cluster status:"
echo "  sinfo"