#!/bin/bash --login
#SBATCH --job-name="vcftools"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --time=0:30:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o admixture.o
#SBATCH -e admixture.e

module load miniconda3/4.12.0
source $EBROOTMINICONDA3/etc/profile.d/conda.sh
conda activate admixture

cd /scratch/user/uqzmezie/Maldives/admixture/subset5_all_dataset

awk '{$1="0";print $0}' subset5_Maldives_all_filtered_LD.bim > subset5_Maldives_all_filtered_LD.bim.tmp
mv subset5_Maldives_all_filtered_LD.bim.tmp subset5_Maldives_all_filtered_LD.bim

for i in {2..10}
do
 admixture --cv subset5_Maldives_all_filtered_LD.bed $i > log${i}.out
done

awk '/CV/ {print $3,$4}' *out | cut -c 4,7-20 > subset5_Maldives_all_filtered_LD.cv.error
