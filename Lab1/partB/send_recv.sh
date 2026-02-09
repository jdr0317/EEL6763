#!/bin/bash

# Joseph Regan 

#SBATCH --job-name=lab1B_sendrecv
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH -t 00:10:00
#SBATCH -o partB_driver.txt
#SBATCH -e partB_driver.err

set -e

module purge
ml gcc openmpi

# compile
mpicc -O2 -o send_recv send_recv.c -lm

A=-10
B=10

echo "Running Part B (Send/Recv)..."

srun --cpu-bind=none --mpi=$HPC_PMIX -n 4  ./send_recv $A $B 100000 > SendRecvR4N100000
srun --cpu-bind=none --mpi=$HPC_PMIX -n 8  ./send_recv $A $B 100000 > SendRecvR8N100000
srun --cpu-bind=none --mpi=$HPC_PMIX -n 16 ./send_recv $A $B 100000 > SendRecvR16N100000
srun --cpu-bind=none --mpi=$HPC_PMIX -n 32 ./send_recv $A $B 100000 > SendRecvR32N100000

srun --cpu-bind=none --mpi=$HPC_PMIX -n 32 ./send_recv $A $B 100    > SendRecvR32N100
srun --cpu-bind=none --mpi=$HPC_PMIX -n 32 ./send_recv $A $B 1000   > SendRecvR32N1000
srun --cpu-bind=none --mpi=$HPC_PMIX -n 32 ./send_recv $A $B 10000  > SendRecvR32N10000

echo "Done. Generated files:"
ls -1 SendRecvR*N* | sort
