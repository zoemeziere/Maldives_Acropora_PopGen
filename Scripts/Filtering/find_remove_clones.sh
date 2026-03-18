#!/bin/bash --login
#SBATCH --job-name="clones"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=500G
#SBATCH --time=24:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o clones.o
#SBATCH -e clones.e

# 1. Find clones
python3 vcf_clone_detect.py --vcf Maldives_imiss90.recode.vcf

# 2. Remove clones
module load miniconda3/4.12.0
source $EBROOTMINICONDA3/etc/profile.d/conda.sh
conda activate vcftools

vcftools --vcf Maldives_ipyrad_raw.vcf --remove clones_replicates_to_remove.txt --recode --out Maldives_raw_noClonesDupli
