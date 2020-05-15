# Yan-Ting Chen March 27, 2020
# load cdo and nco module before executing the script.

year=2012
monthStart=1
monthEnd=12

job_name='ctrl_allsky'
proj_dir='/home/yantingc/projects/rrg-yihuang-ad/yantingc/co2_forcing_seasonal/output/'${job_name}'/'
input_dir=${proj_dir}'raw_24hour/'
output_dir_daily=${proj_dir}'daily/'
output_dir_monthly=${proj_dir}'monthly/'
output_dir_monthmean=${proj_dir}'monthly_mean/'

echo $(date) > RUNTIME

for ((n_month=${monthStart}; n_month<=${monthEnd}; n_month++));
do
  dayinmonth=$(cal $n_month $year | egrep -v [a-z] | wc -w)

  for ((nday=1; nday<=${dayinmonth}; nday++));
  do
    id=$(printf "%04d%02d%02d" $year $n_month $nday)   #add leading zero. 0 sets leading zero, 2 sets 2 digits
    # hourly to daily mean
    cdo -s daymean -setmissval,NaN "${input_dir}output_lw_era5emis_land*${id}_allsky.nc" "${output_dir_daily}${id}_${job_name}.nc"
  done

  # concatenate daily mean to month-long
  month_id=$(printf "%04d%02d" $year $n_month)

 cd ${output_dir_daily}
 # use nco ncrcat to concatenate files (cdo doesn't treat time dimension correctly as I suppose)
 ncrcat ${month_id}??_${job_name}.nc ${output_dir_monthly}${month_id}_${job_name}.nc

 # average over a month
 cdo -s monmean -setmissval,NaN "${output_dir_monthly}${month_id}_${job_name}.nc" "${output_dir_monthmean}${month_id}_mean_${job_name}.nc"
 echo "${month_id}.nc done"

done

echo $(date) >> RUNTIME
