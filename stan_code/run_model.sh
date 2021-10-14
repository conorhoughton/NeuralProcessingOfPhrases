#!/usr/bin/env bash
clear
reset

MODEL=$1
NUM_ITER=$2
FREQ=$3
IDEN=$4

Rscript --vanilla sample_model.r $MODEL $NUM_ITER $FREQ $IDEN |& tee output.txt
