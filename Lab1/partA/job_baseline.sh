#!/bin/bash

# Joseph Regan 

#SBATCH --job-name=lab1A_base
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH -t 00:05:00
#SBATCH -o baseline.txt
#SBATCH -e baseline.err

set -e

module purge
ml gcc openmpi

mpicc -O2 -o mat_mult_baseline mat_mult_baseline.c
srun --cpu-bind=none --mpi=$HPC_PMIX ./mat_mult_baseline
