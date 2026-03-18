#!/bin/bash --login
#SBATCH --job-name="genepop_M1"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=72:00:00
#SBATCH --account=a_senv_mbos
#SBATCH --partition=general
#SBATCH -o genepop_M1.o
#SBATCH -e genepop_M1.e

module load r/4.2.1-foss-2022a

Rscript genepop_M1.R

library(genepop)

M1_genepop_run <- ibd(inputFile= "M1_genepop.txt", outputFile = "M1_genepop_out.txt", statistic='a', dataType='Diploid', settingsFile = '', geographicScale='2D', verbose = interactive())

M2_genepop_run <- ibd(inputFile= "M2_genepop.txt", outputFile = "M2_genepop_out.txt", statistic='a', dataType='Diploid', settingsFile = '', geographicScale='2D', verb$
