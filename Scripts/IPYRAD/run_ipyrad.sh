#!/bin/bash --login
#SBATCH --job-name="ipyrad"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=400G
#SBATCH --time=24:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o ipyrad.o
#SBATCH -e ipyrad.e

module load miniconda3/4.12.0
source $EBROOTMINICONDA3/etc/profile.d/conda.sh
conda activate ipyrad

# ipyrad -p params-file.txt -s 123456 -c 40 -t 4 -f
# ipyrad -p params-file.txt -b branched - Ahya_W49_A39-1C_TGCG
ipyrad -p params-branched.txt -s 7 -c 40 -t 4 -f
