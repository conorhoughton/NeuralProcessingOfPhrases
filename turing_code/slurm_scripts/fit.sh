#!/bin/bash -login

#SBATCH --mem=5000M
#SBATCH --partition=cpu

#SBATCH --job-name=fit
#SBATCH --time=4-00:00:00

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8


module add languages/julia/1.6.3

cd $SLURM_SUBMIT_DIR

srun julia -t8 ./fit.jl --runC $2 --freqC $1 --name $3
