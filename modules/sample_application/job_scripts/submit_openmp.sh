#!/bin/bash
#SBATCH --job-name=openmp_example
#SBATCH --output=openmp_example_%j.out
#SBATCH --error=openmp_example_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=00:05:00
#SBATCH --partition=compute

# Print some information about the job
echo "Running on host: $(hostname)"
echo "Starting at: $(date)"
echo "Job directory: $(pwd)"
echo "Job ID: $SLURM_JOB_ID"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "Number of tasks: $SLURM_NTASKS"
echo "CPUs per task: $SLURM_CPUS_PER_TASK"

# Set OpenMP environment variables
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PROC_BIND=true
export OMP_PLACES=cores

# Print OpenMP environment
echo "OpenMP Environment:"
echo "OMP_NUM_THREADS: $OMP_NUM_THREADS"
echo "OMP_PROC_BIND: $OMP_PROC_BIND"
echo "OMP_PLACES: $OMP_PLACES"

# Run the OpenMP application
echo "Running OpenMP example application..."
$HOME/apps/openmp_example/openmp_example

# Print job completion information
echo "Job completed at: $(date)"