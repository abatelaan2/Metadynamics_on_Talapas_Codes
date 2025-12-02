#!/bin/bash
#SBATCH --partition=compute      ### queue to submit to
#SBATCH --job-name=run_plumed_sim        ### job name
#SBATCH --output=run_plumed_sim_jobout         ### file in which to store job stdout
#SBATCH --error=run_plumed_sim_joberr          ### file in which to store job stderr
#SBATCH --time=0-00:30:00        ### Wall clock time limit in HH:MM:SS
#SBATCH --nodes=2               ### number of nodes to use
#SBATCH --ntasks-per-node=24    ### nuimber of tasks to launch per node
#SBATCH --cpus-per-task=1       ### number of cores for each task
#SBATCH --mail-type=begin  # email me when the job starts
#SBATCH --mail-type=end    # email me when the job finishes
#SBATCH --account=ch447_547      ### Account used for job submission

module purge
module load gcc/13.1.0
module load openmpi/4.1.6
module load gromacs/2024.3-plumed-2.11.0

#export PLUMED_KERNEL="/gpfs/packages/plumed/2.9.2/src/lib/libplumedKernel.so"

gmx_mpi mdrun -s topol.tpr -nsteps 5000000 -plumed plumed.dat
