#!/bin/bash --login
#SBATCH --job-name="vcftools"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=4:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o plink.o
#SBATCH -e plink.e

# LD prunning and PCA on all, Maldives, M1 and M2

module load plink/2.00a3.6-gcc-11.3.0

plink2 --vcf Maldives_all_filtered.recode.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 200 20 0.5 --out Maldives_all_filtered_LD
plink2 --vcf Maldives_all_filtered.recode.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --extract Maldives_all_filtered_LD.prune.in --make-bed --pca --out Maldives_all_filtered_LD

plink2 --vcf Maldives_Maldives_filtered.recode.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 200 20 0.5 --out Maldives_Maldives_filtered_LD
plink2 --vcf Maldives_Maldives_filtered.recode.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --extract Maldives_Maldives_filtered_LD.prune.in --make-bed --pca --out Maldives_Maldives_filtered_LD

plink2 --vcf Maldives_M1/Maldives_M1_filtered.recode.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 200 20 0.5 --out Maldives_M1_filtered_LD
plink2 --vcf Maldives_M1/Maldives_M1_filtered.recode.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --extract Maldives_M1_filtered_LD.prune.in --make-bed --pca --out Maldives_M1_filtered_LD

plink2 --vcf Maldives_M2/Maldives_M2_filtered.recode.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 200 20 0.5 --out Maldives_M2_filtered_LD
plink2 --vcf Maldives_M2/Maldives_M2_filtered.recode.vcf --double-id --allow-extra-chr --set-missing-var-ids @:# --extract Maldives_M2_filtered_LD.prune.in --make-bed --pca --out Maldives_M2_filtered_LD
