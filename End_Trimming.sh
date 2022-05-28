#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=Trim_this_shit
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=12
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=arrice@ttu.edu
#SBATCH --array=1-27
#SBATCH --mail-type=ALL

#### MAKE SURE TO RENAME THINGS BEFORE RUNNING THIS!!!!

workdir=/lustre/scratch/arrice/WBNU_project_round2

basename_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/RAD_basenames.txt | tail -n1 )

# run bbduk
/lustre/work/jmanthey/bbmap/bbduk.sh in=${workdir}/15_STACKS/${basename_array}.fq.gz out=${workdir}/15_STACKS/trimmed/${basename_array}_trimmed.fq.gz ftl=4
# "DUK" stands for decontamination using kmers. It combines a bunch of tools for quality trimming, adapter trimming, filtering, etc.
# "in"= Input file. "out"= Output file.
# "ftl=4" trims the leftmost 4 bases.
