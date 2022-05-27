#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=align_RAD_data
#SBATCH --partition quanah
#SBATCH --nodes=1 --ntasks=12
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-27
#SBATCH --mail-user=arrice@ttu.edu
#SBATCH --mail-type=ALL

module load intel java bwa samtools singularity

export SINGULARITY_CACHEDIR="/lustre/work/arrice/singularity-cachedir"

# define main working directory
workdir=/lustre/scratch/arrice/WBNU_project_round2

basename_array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/RAD_basenames.txt | tail -n1 )

# define the reference genome
refgenome=/home/arrice/WBNU_refgenome/New_one/wbnu.fasta

# run bwa mem
bwa mem -t 12 ${refgenome} ${workdir}/15_STACKS/trimmed/${basename_array}_trimmed.fq.gz > ${workdir}/15_STACKS/aligned/${basename_array}.sam
# This maps sequences to the reference genome.
# -t denotes number of threads.
# Creates a .sam file.

# convert sam to bam
samtools view -b -S -o ${workdir}/15_STACKS/aligned/${basename_array}.bam ${workdir}/15_STACKS/aligned/${basename_array}.sam

# remove sam
rm ${workdir}/15_STACKS/aligned/${basename_array}.sam

# clean the bam, soft-clipping beyond-end-of-reference alignments and setting MAPQ to 0 for unmapped reads.
# Probably not necessary for this but couldn't hurt.
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk CleanSam -I ${workdir}/15_STACKS/aligned/${basename_array}.bam -O ${workdir}/15_STACKS/aligned/${basename_array}_cleaned.bam

# remove the raw bam
rm ${workdir}/15_STACKS/aligned/${basename_array}.bam

# sort the cleaned bam file
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk SortSam -I ${workdir}/15_STACKS/aligned/${basename_array}_cleaned.bam -O ${workdir}/15_STACKS/aligned/${basename_array}_cleaned_sorted.bam --Sam --SORT_ORDER coordinate

# remove the cleaned bam file
rm ${workdir}/15_STACKS/aligned/${basename_array}_cleaned.bam

# add read groups to sorted and cleaned bam file. 
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk AddOrReplaceReadGroups -I ${workdir}/15_STACKS/aligned/${basename_array}_cleaned_sorted.bam -O ${workdir}/15_STACKS/aligned/${basename_array}_final_RAD.bam --RGLB 1 --RGPL illumina --RGPU unit1 --RGSM ${basename_array}

# remove cleaned and sorted bam file
rm ${workdir}/15_STACKS/aligned/${basename_array}_cleaned_sorted.bam

# index the final bam file
samtools index ${workdir}/15_STACKS/aligned/${basename_array}_final_RAD.bam
