#!/bin/bash --login
#SBATCH --job-name="vcftools"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=4:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o vctools.o
#SBATCH -e vcftools.e

module load miniconda3/4.12.0
source $EBROOTMINICONDA3/etc/profile.d/conda.sh
conda activate vcftools

# FILTERING DATASET WITH OUTGROUPS #

# 1. Remove indels, samples with >90% missing data, outliers, clones and duplicates
vcftools --vcf Maldives_ipyrad_raw.vcf --missing-indv --out Maldives_ipyrad_raw
awk '$5 > 0.90' Maldives_ipyrad_raw.imiss | cut -f1 > imiss_raw_90_to_remove.txt

vcftools --vcf Maldives_ipyrad_raw.vcf --remove-indels --remove imiss_raw_90_to_remove.txt \
	--remove outliers_Maldives.txt --remove clones_replicates_to_remove.txt \
	--recode --out Maldives_all_imiss90_noOutClonesDupli

#Inspect missing data
vcftools --vcf Maldives_all_imiss90_noOutClonesDupli.recode.vcf --missing-indv --out Maldives_all_imiss90_noOutClonesDupli
vcftools --vcf Maldives_all_imiss90_noOutClonesDupli.recode.vcf --missing-site --out Maldives_all_imiss90_noOutClonesDupli

# 2. Filter sites
vcftools --vcf Maldives_all_imiss90_noOutClonesDupli.recode.vcf --min-meanDP 5 --max-meanDP 50 --max-missing 0.8 --mac 3 --min-alleles 2 --max-alleles 2 --recode --out Maldives_all_filtered

#Inspect missing data
vcftools --vcf Maldives_all_filtered.recode.vcf --missing-indv --out Maldives_all_filtered
vcftools --vcf Maldives_all_filtered.recode.vcf --missing-site --out Maldives_all_filtered

# FILTER DATASET WITH MALDIVES SAMPLES ONLY #

# 1. Remove outgroup samples
vcftools --vcf Maldives_ipyrad_raw.vcf --remove outgroup_all_samples.txt --recode --out Maldives_Maldives_raw

#Inspect sum stats
vcftools --vcf Maldives_Maldives_raw.recode.vcf --missing-indv --out Maldives_Maldives_raw
vcftools --vcf Maldives_Maldives_raw.recode.vcf --missing-site --out Maldives_Maldives_raw
vcftools --vcf Maldives_Maldives_raw.recode.vcf --het --out Maldives_Maldives_raw
vcftools --vcf Maldives_Maldives_raw.recode.vcf --site-mean-depth --out Maldives_Maldives_raw
vcftools --vcf Maldives_Maldives_raw.recode.vcf --depth --out Maldives_Maldives_raw

# 2. Remove indels, samples with >90% missing data, outliers, clones and duplicates
vcftools --vcf Maldives_Maldives_raw.recode.vcf --missing-indv --out Maldives_Maldives_raw
awk '$5 > 0.90' Maldives_Maldives_raw.imiss | cut -f1 > imiss_Maldives_90_to_remove.txt

vcftools --vcf Maldives_Maldives_raw.recode.vcf --remove-indels --remove imiss_Maldives_90_to_remove.txt \
	--remove outliers_Maldives.txt --remove clones_replicates_to_remove.txt \
	--recode --out Maldives_Maldives_imiss90_noOutClonesDupli

#Inspect missing data
vcftools --vcf Maldives_Maldives_imiss90_noOutClonesDupli.recode.vcf --missing-indv --out Maldives_Maldives_imiss90_noOutClonesDupli
vcftools --vcf Maldives_Maldives_imiss90_noOutClonesDupli.recode.vcf --missing-site --out Maldives_Maldives_imiss90_noOutClonesDupli

# 3. Filter sites
vcftools --vcf Maldives_Maldives_imiss90_noOutClonesDupli.recode.vcf --min-meanDP 5 --max-meanDP 50 --max-missing 0.8 --mac 3 --min-alleles 2 --max-alleles 2 --recode --out Maldives_Maldives_filtered

#Inspect missing data
vcftools --vcf Maldives_Maldives_filtered.recode.vcf --missing-indv --out Maldives_Maldives_filtered
vcftools --vcf Maldives_Maldives_filtered.recode.vcf --missing-site --out Maldives_Maldives_filtered


# FILTER DATASET FOR M1 SAMPLES ONLY #

# 1. Keep only M1 samples
vcftools --vcf Maldives/Maldives/Maldives_Maldives_imiss90_noOutClonesDupli.recode.vcf --keep M1_only_samples.txt --recode --out Maldives_Maldives_imiss90_noOutClonesDupli_M1

# 2. Filter sites
vcftools --vcf Maldives_Maldives_imiss90_noOutClonesDupli_M1.recode.vcf --min-meanDP 5 --max-meanDP 50 --max-missing 0.8 --mac 3 --min-alleles 2 --max-alleles 2 --recode --out Maldives_M1_filtered

#Inspect missing data
vcftools --vcf Maldives_M1_filtered.recode.vcf --missing-indv --out Maldives_M1_filtered
vcftools --vcf Maldives_M1_filtered.recode.vcf --missing-indv --out Maldives_M1_filtered

# FILTER DATASET FOR M2 SAMPLES ONLY #

# 1. Keep only M2 samples
vcftools --vcf Maldives_Maldives_imiss90_noOutClonesDupli.recode.vcf --keep M2_only_samples.txt --recode --out Maldives_Maldives_imiss90_noOutClonesDupli_M2

# 2. Filter sites
vcftools --vcf Maldives_Maldives_imiss90_noOutClonesDupli_M2.recode.vcf --min-meanDP 5 --max-meanDP 50 --max-missing 0.8 --mac 3 --min-alleles 2 --max-alleles 2 --recode --out Maldives_M2_filtered

#Inspect missing data
vcftools --vcf Maldives_M2_filtered.recode.vcf --missing-indv --out Maldives_M2_filtered
vcftools --vcf Maldives_M2_filtered.recode.vcf --missing-indv --out Maldives_M2_filtered
