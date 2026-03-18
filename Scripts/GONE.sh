#!/bin/bash --login
#SBATCH --job-name="gone"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=24:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o gone.o
#SBATCH -e gone.e

module load anaconda3/2022.05
source $EBROOTANACONDA3/etc/profile.d/conda.sh
conda activate GONE

module load vcftools

# Remove short contigs
vcftools --vcf Maldives_M1_filtered.recode.vcf \
         --chr OZ197743.1 --chr OZ197744.1 --chr OZ197745.1 --chr OZ197746.1 \
         --chr OZ197747.1 --chr OZ197748.1 --chr OZ197749.1 --chr OZ197750.1 \
         --chr OZ197751.1 --chr OZ197752.1 --chr OZ197753.1 --chr OZ197754.1 \
         --chr OZ197755.1 --chr OZ197756.1 \
         --recode --out Maldives_M1_filtered_chrom

vcftools --vcf Maldives_M2_filtered.recode.vcf \
         --chr OZ197743.1 --chr OZ197744.1 --chr OZ197745.1 --chr OZ197746.1 \
         --chr OZ197747.1 --chr OZ197748.1 --chr OZ197749.1 --chr OZ197750.1 \
         --chr OZ197751.1 --chr OZ197752.1 --chr OZ197753.1 --chr OZ197754.1 \
         --chr OZ197755.1 --chr OZ197756.1 \
         --recode --out Maldives_M2_filtered_chrom

# Zip and tabix
bgzip -c Maldives_Maldives_filtered_chrom.recode.vcf > Maldives_Maldives_filtered_chrom.recode.vcf.gz
tabix -p vcf Maldives_Maldives_filtered_chrom.recode.vcf.gz

# Run GONE for each species
GONE2/gone2 Maldives_M1_filtered_chrom.recode.vcf -r 1
GONE2/gone2 Maldives_M2_filtered_chrom.recode.vcf -r 1

# Run GONE with confidence intervals
VCF="../../Maldives_M1_filtered_chrom.recode.vcf.gz" # For M1
VCF="../../Maldives_M2_filtered_chrom.recode.vcf.gz" # For M2

REPS=50

NSNPS=40400 # for M1
NSNPS=32100 # for M2

GONE2="../../GONE2/gone2"

for i in $(seq 1 $REPS); do
    echo "Creating replicate $i..."
    bcftools query -f '%CHROM\t%POS\n' $VCF | shuf -n $NSNPS > rep${i}_positions.txt
    bcftools view -R rep${i}_positions.txt $VCF -Oz -o gone_rep${i}.vcf
    $GONE2 gone_rep${i}.vcf -r 1
done

# Run GONE for each population
GONE2/gone2 taxon_M2/Maldives_M2_THAA.vcf -r 1
GONE2/gone2 taxon_M2/Maldives_M2_HUVADHOO.vcf -r 1
GONE2/gone2 taxon_M2/Maldives_M2_LAAMU.vcf -r 1
