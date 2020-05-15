#!/bin/bash
# check and create output directory if not existed
year=2012
month=1
monthEnd=1 
project_name='co2_forcing_seasonal/'
project_dir='/lustre03/project/6003571/yantingc/'${project_name}
scratch_dir='/scratch/yantingc/'${project_name}
output_scrt=${scratch_dir}'ctrl_clear/' 
output_proj=${project_dir}'output/ctrl_clear/raw_24hour/'

#check/create if output dir exists
if [ ! -d "${output_proj}" ]; then
  mkdir "${output_proj}" 
fi

cd ${scratch_dir}

if [ ! -d "${output_scrt}" ]; then
  mkdir "${output_scrt}"
fi

for ((n_month=${month}; n_month<=${monthEnd}; n_month++));
do
  dayinmonth=$(cal $n_month $year | egrep -v [a-z] | wc -w)

  for ((nday=1; nday<=${dayinmonth}; nday++));
  #for ((nday=1; nday<=1; nday++));
  do
  
    id=$(printf "%04d%02d%02d" $year $n_month $nday)   #add leading zero2. 0 means leading zero, 2 means 2 digits

    # create a folder for temporary results
    if [ ! -d ${output_scrt}"${id}" ]; then
      mkdir ${output_scrt}"${id}"
    fi

    cd ${output_scrt}"${id}/"
    rm -f *.out
    cp ${project_dir}script/main_lw.m .
    cp ${project_dir}script/submit_job/submit.sh .

    sed -i "15c   time     = '${id}';" main_lw.m    #modify 'time' at 15th line in main.m
    sed -i "19c   outdir   = '$PWD/';" main_lw.m
    sed -i "2c #SBATCH --job-name=rrtmg_${id}" submit.sh
    sed -i "6c #SBATCH --output=rrtmg_${id}.out" submit.sh
    sed -i "14c cp ${output_scrt}${id}/*.nc ${output_proj}" submit.sh 
    sbatch submit.sh

  done
done

