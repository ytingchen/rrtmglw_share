#!/bin/bash
#SBATCH --job-name=rrtmg_20120103
#SBATCH --account=rrg-yihuang-ad_cpu
#SBATCH --time=1-08:59 		# time (DD-HH:MM)
#SBATCH --mem=1024
#SBATCH --output=rrtmg_20120103.out
echo "SLURM_JOB_ID = $SLURM_JOB_ID"
echo "SLURM_JOB_NODELIST = $SLURM_JOB_NODELIST"

echo $(date) > RUNTIME
module load matlab/2018a
srun matlab -nodisplay -nodesktop -singleCompThread -r "main_lw_allsky;exit"

cp /scratch/yantingc/co2_forcing_seasonal/ctrl_allsky/20120103/*.nc /home/yantingc/projects/rrg-yihuang-ad/yantingc/co2_forcing_seasonal/output/ctrl_allsky/raw_24hour/

echo $(date) >> RUNTIME
