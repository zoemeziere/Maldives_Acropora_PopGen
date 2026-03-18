#!/bin/bash --login
#SBATCH --job-name="smc2"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=100G
#SBATCH --time=48:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o smc2.o
#SBATCH -e smc2.e

module load miniconda3/4.12.0
source $EBROOTMINICONDA3/etc/profile.d/conda.sh
conda activate smcpp
module load bcftools

# step 1

VCF="Maldives_M1_HUVADHOO.vcf.gz"
POP="Huva"
SAMPLES=$(bcftools query -l $VCF | paste -sd, -)
FAI="../../ref_genome/GCA_964291705.1_jaAcrHyac4.1_genomic.fna.fai"
CONTIGS="contigs.txt"

while read CONTIG; do
    # Get contig length from .fai
    LENGTH=$(grep "^$CONTIG" $FAI | cut -f2)
    if [ -z "$LENGTH" ]; then
        echo "Warning: length for $CONTIG not found, skipping"
        continue
    fi
    echo "Processing $CONTIG (length $LENGTH)..."
    OUT="${CONTIG}.smc"
    smc++ vcf2smc --length "$LENGTH" "$VCF" "$OUT" "$CONTIG" "$POP:$SAMPLES"
done < "$CONTIGS"

# step 2

smc++ estimate -o analysis_Huva/  --cores 30 --em-iterations 50 --timepoints 20 250000 --knots 40 --Nmax 100000 1.25e-8 *.smc

# Step 3

smc++ plot -c smc_M1_Huva.pdf analysis_Huva/model.final.json
