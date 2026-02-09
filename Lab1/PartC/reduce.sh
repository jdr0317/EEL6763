#!/bin/bash
#SBATCH --job-name=lab1C_Reduce
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH -t 00:10:00
#SBATCH -o partC_driver.txt
#SBATCH -e partC_driver.err

set -e

module purge
ml gcc openmpi

# compile
mpicc -O2 -o reduce reduce.c -lm

A=-10
B=10

echo "Running Part B (Reduce)..."

srun --cpu-bind=none --mpi=$HPC_PMIX -n 4  ./reduce $A $B 100000 > ReduceR4N100000
srun --cpu-bind=none --mpi=$HPC_PMIX -n 8  ./reduce $A $B 100000 > ReduceR8N100000
srun --cpu-bind=none --mpi=$HPC_PMIX -n 16 ./reduce $A $B 100000 > ReduceR16N100000
srun --cpu-bind=none --mpi=$HPC_PMIX -n 32 ./reduce $A $B 100000 > ReduceR32N100000

srun --cpu-bind=none --mpi=$HPC_PMIX -n 32 ./reduce $A $B 100    > ReduceR32N100
srun --cpu-bind=none --mpi=$HPC_PMIX -n 32 ./reduce $A $B 1000   > ReduceR32N1000
srun --cpu-bind=none --mpi=$HPC_PMIX -n 32 ./reduce $A $B 10000  > ReduceR32N10000

echo "Done. Generated files:"
ls -1 ReduceR*N* | sort
