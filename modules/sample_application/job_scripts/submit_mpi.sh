#!/bin/bash
#SBATCH --job-name=mpi_hello_world
#SBATCH --output=mpi_hello_world_%j.out
#SBATCH --error=mpi_hello_world_%j.err
#SBATCH --nodes=2
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:05:00
#SBATCH --partition=compute

# Print some information about the job
echo "Running on host: $(hostname)"
echo "Starting at: $(date)"
echo "Job directory: $(pwd)"
echo "Job ID: $SLURM_JOB_ID"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "Number of tasks: $SLURM_NTASKS"
echo "Tasks per node: $SLURM_NTASKS_PER_NODE"

# Load any required modules
module load openmpi

# Set the OpenMPI environment
export OMPI_MCA_btl_openib_allow_ib=1
export OMPI_MCA_mpi_yield_when_idle=1

# Run the MPI application
echo "Running MPI Hello World application..."
mpirun -np $SLURM_NTASKS --map-by ppr:$SLURM_NTASKS_PER_NODE:node $HOME/apps/mpi_hello_world/mpi_hello_world

# Print job completion information
echo "Job completed at: $(date)"