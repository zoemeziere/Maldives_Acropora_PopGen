#!/bin/bash --login
#SBATCH --job-name="pixy"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=48:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o pixy.o
#SBATCH -e pixy.e

module load bcftools

#cd bam_files
#bcftools mpileup -f ../../ref_genome/GCA_964291705.1_jaAcrHyac4.1_genomic.fna  -b bam_M1.txt | bcftools call -m -Oz -f GQ -o M1_allsites
#bcftools mpileup -f ../../ref_genome/GCA_964291705.1_jaAcrHyac4.1_genomic.fna  -b bam_M2.txt | bcftools call -m -Oz -f GQ -o M2_allsites

module load vcftools

#vcftools --gzvcf M2_allsites.vcf.gz --remove-indels --max-missing 0.8 --recode --out M2_allsites_SF
#vcftools --gzvcf M2_allsites_SF.recode.vcf.gz --max-maf 0 --recode --out M2_allsites_SF_invar
#vcftools --gzvcf M2_allsites_SF.recode.vcf.gz --mac 3 --min-alleles 2 --max-alleles 2 --min-meanDP 5 --max-meanDP 50 --recode --out M1_allsites_SF_var

#bgzip M1_allsites_SF_var.recode.vcf
#tabix M1_allsites_SF_var.recode.vcf.gz

#bgzip M2_allsites_SF_invar.recode.vcf
#tabix M2_allsites_SF_invar.recode.vcf.gz

#module load bcftools

bcftools query -l M2_allsites_SF_var.recode.vcf.gz > samples_var.txt
bcftools reheader -s samples_var.txt -o M2_allsites_SF_invar.fixed.vcf.gz M2_allsites_SF_invar.recode.vcf.gz
bcftools index M2_allsites_SF_invar.fixed.vcf.gz

bcftools concat --allow-overlaps M2_allsites_SF_var.recode.vcf.gz M2_allsites_SF_invar.fixed.vcf.gz -O z -o M2_allsites_SF_combined.vcf.gz
tabix M2_allsites_SF_combined.vcf.gz
