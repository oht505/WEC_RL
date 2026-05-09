#!/bin/bash
#SBATCH -J valid_Seed2026
#SBATCH -o valid_Seed2026.out
#SBATCH -e valid_Seed2026.err
#SBATCH --partition=share
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH --time=24:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=ohhyun@oregonstate.edu

module load matlab/2025a

matlab -nodisplay -nosplash -batch "PPO_validate_plot_EpisodeAgents_lstm"
