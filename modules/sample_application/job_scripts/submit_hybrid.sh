#!/bin/bash
#SBATCH --job-name=hybrid_example
#SBATCH --output=hybrid_example_%j.out
#SBATCH --error=hybrid_example_%j.err
#SBATCH --nodes=2
#SBATCH --ntasks=4
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=4
#SBATCH --time=00:10:00
#SBATCH --partition=compute

# Print some information about the job
echo "Running on host: $(hostname)"
echo "Starting at: $(date)"
echo "Job directory: $(pwd)"
echo "Job ID: $SLURM_JOB_ID"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "Number of tasks: $SLURM_NTASKS"
echo "Tasks per node: $SLURM_NTASKS_PER_NODE"
echo "CPUs per task: $SLURM_CPUS_PER_TASK"

# Load any required modules
module load openmpi

# Set the OpenMPI environment
export OMPI_MCA_btl_openib_allow_ib=1
export OMPI_MCA_mpi_yield_when_idle=1

# Set OpenMP environment variables
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PROC_BIND=true
export OMP_PLACES=cores

# Print hybrid environment
echo "Hybrid MPI/OpenMP Environment:"
echo "MPI processes: $SLURM_NTASKS"
echo "OpenMP threads per process: $OMP_NUM_THREADS"
echo "Total parallelism: $((SLURM_NTASKS * OMP_NUM_THREADS)) threads"
echo "OMP_PROC_BIND: $OMP_PROC_BIND"
echo "OMP_PLACES: $OMP_PLACES"

# This script assumes you have a hybrid MPI+OpenMP application
# For demonstration, we'll just run the MPI example which will show the distribution
echo "Running Hybrid MPI+OpenMP example application..."
echo "Note: This is a placeholder for a true hybrid application"
mpirun -np $SLURM_NTASKS --map-by ppr:$SLURM_NTASKS_PER_NODE:node --bind-to core $HOME/apps/mpi_hello_world/mpi_hello_world

echo "For a real hybrid application, each MPI process would use $OMP_NUM_THREADS OpenMP threads"
echo "Example command for a real hybrid application would be:"
echo "mpirun -np $SLURM_NTASKS --map-by ppr:$SLURM_NTASKS_PER_NODE:node --bind-to core $HOME/apps/hybrid_example/hybrid_example"

# Print job completion information
echo "Job completed at: $(date)"