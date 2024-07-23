#! /usr/bin/env bash

#partition - defq, bigmem and xtreme
#SBATCH --job-name=nf-cellranger
#SBATCH --ntasks=1
#SBATCH --partition=defq
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1G
#SBATCH --time=12:00:00
#SBATCH -o slurm.%A.o
#SBATCH -e slurm.%A.e

module load nextflow/22.04.3
module load singularity/3.8.0

nextflow run cellranger.nf -c ./cellranger_conf/run.config -resume -profile slurm

module unload nextflow/22.04.3
module unload singularity/3.8.0