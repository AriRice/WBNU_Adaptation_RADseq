#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=RADtags
#SBATCH --partition nocona
#SBATCH --nodes=1 --ntasks=12
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=arrice@ttu.edu
#SBATCH --mail-type=ALL

. ~/anaconda3/etc/profile.d/conda.sh
conda activate STACKS

process_radtags -p /lustre/scratch/arrice/WBNU_project_round2/14_RADseq_data/ -i gzfastq  -o /lustre/scratch/arrice/WBNU_project_round2/15_STACKS -e ndeI -c -q

# Window size of 15 and a quality score threshhold >10 is the default setting for the -q tag. So I think this is fine.
