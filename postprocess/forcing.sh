# Yan-Ting Chen May 4, 2020
# This script extracts OLR, sfc downward LW and sfc net LW and calculates 2xco2 forcing.

year=2012
monthStart=1
monthEnd=12

job_ctrl='ctrl_allsky'
job_2xco2='2xco2_allsky'
jobname='2xco2_allsky'
proj_dir='/home/yantingc/projects/rrg-yihuang-ad/yantingc/co2_forcing_seasonal/output/'
output_dir=${proj_dir}'forcing_2xco2_allsky/'
output_dir_monthmean=${proj_dir}'monthly_mean/'

echo $(date) > RUNTIME

for ((n_month=${monthStart}; n_month<=${monthEnd}; n_month++));
do
  dayinmonth=$(cal $n_month $year | egrep -v [a-z] | wc -w)

  id=$(printf "%04d%02d" $year $n_month)
  cdo -s select,name=toa_lw,sfc_fnt_lw,sfc_fdn_lw -sub "${proj_dir}${job_2xco2}/monthly/${id}_${job_2xco2}.nc" "${proj_dir}${job_ctrl}/monthly/${id}_${job_ctrl}.nc" "${output_dir}forcing_${id}_${jobname}.nc"
  cdo -s select,name=toa_lw,sfc_fnt_lw,sfc_fdn_lw -sub "${proj_dir}${job_2xco2}/monthly_mean/${id}_mean_${job_2xco2}.nc" "${proj_dir}${job_ctrl}/monthly_mean/${id}_mean_${job_ctrl}.nc" "${output_dir}forcing_mean_${id}_${jobname}.nc"

  echo "${id}.nc done"

done

echo $(date) >> RUNTIME
