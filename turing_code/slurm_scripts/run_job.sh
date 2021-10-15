#!/bin/bash

    SLURM_JOBID=$(sbatch --parsable fit.sh $1 $2 $3)
    sleep 1
    echo $(date -d now) "," ${SLURM_JOBID} "," $1 "," $2 "," $3 "," $4 | tee -a log.txt


