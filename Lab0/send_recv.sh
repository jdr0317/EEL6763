#!/bin/bash
#SBATCH --job-name=helloWorld_MPI
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=youremailaddress
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --nodes=4
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1000mb
#SBATCH -t 00:05:00
#SBATCH -o myoutput_sendrecv
#SBATCH -e myerr_sendrecv
srun --mpi=$HPC_PMIX ./send_recv
