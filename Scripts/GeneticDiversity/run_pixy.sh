#!/bin/bash --login
#SBATCH --job-name="pixy"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=48:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o pixy2.o
#SBATCH -e pixy2.e

module load anaconda3/2022.05
source $EBROOTANACONDA3/etc/profile.d/conda.sh
conda activate pixy2

pixy --stats pi dxy fst watterson_theta tajima_d --vcf M2_allsites_SF_combined.vcf.gz --populations pop_M2.txt --window_size 10000 --n_cores 4 --output_folder output
