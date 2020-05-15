#!/bin/bash
# check and create output directory if not existed

########################################################
### Always check back on the files modified with sed!!!
########################################################

year=2012
month=2
monthEnd=12
project_name='co2_forcing_seasonal/'
project_dir='/lustre03/project/6003571/yantingc/'${project_name}
scratch_dir='/scratch/yantingc/'${project_name}
output_scrt=${scratch_dir}'2xco2_allsky/' 
output_proj=${project_dir}'output/2xco2_allsky/raw_24hour/'

#check/create if output dir exists
if [ ! -d "${output_proj}" ]; then
  mkdir "${output_proj}" 
fi

if [ ! -d "${output_scrt}" ]; then
  mkdir "${output_scrt}"
fi

#path_local=$PWD'/output/'

for ((n_month=${month}; n_month<=${monthEnd}; n_month++));
do
  dayinmonth=$(cal $n_month $year | egrep -v [a-z] | wc -w)

  for ((nday=1; nday<=${dayinmonth}; nday++));
 # for ((nday=1; nday<=1; nday++));
  do
  
    id=$(printf "%04d%02d%02d" $year $n_month $nday)   #add leading zero2. 0 means leading zero, 2 means 2 digits

    # create a folder for temporary results
    if [ ! -d ${output_scrt}"${id}" ]; then
      mkdir ${output_scrt}"${id}"
    fi

    cd ${output_scrt}"${id}/"
    rm -f *.out
    cp ${project_dir}script/main_lw_allsky_2xco2.m .
    cp ${project_dir}script/submit_job/submit_2xco2_allsky.sh .

    sed -i "15c   time     = '${id}';" main_lw_allsky_2xco2.m    #modify 'time' at 15th line in main.m
    sed -i "17c   outdir   = '$PWD/';" main_lw_allsky_2xco2.m
    sed -i "2c #SBATCH --job-name=2xco2_${id}" submit_2xco2_allsky.sh
    sed -i "6c #SBATCH --output=2xco2_${id}.out" submit_2xco2_allsky.sh
    sed -i "14c cp ${output_scrt}${id}/*.nc ${output_proj}" submit_2xco2_allsky.sh 
    sbatch submit_2xco2_allsky.sh

  done
done

