#!/bin/bash -login
#SBATCH --nodes=1
#SBATCH --mem=5000M
#SBATCH --partition=cpu
#sBATCH --ntasks-per-node=8
#SBATCH --job-name=fit
#SBATCH --time=4-00:00:00



module add languages/julia/1.6.3

cd $SLURM_SUBMIT_DIR

srun julia -t8 ./fit.jl --runC $2 --freqC $1 --name $3
