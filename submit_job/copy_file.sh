#!/bin/bash
# This script copy .nc file in scratch folder if exists
# non-existed file ID is forwarded into badfile_copy.txt
# Yan-Ting Chen, March 20, 2020

year=2012
month=1
monthEnd=12
project_name='co2_forcing_seasonal/'
project_dir='/home/yantingc/projects/rrg-yihuang-ad/yantingc/'${project_name}
scratch_dir='/scratch/yantingc/'${project_name}
#output_scrt=${scratch_dir}'2xco2/output/' 
output_proj=${project_dir}'output/ctrl_clear/raw_24hour/'

rm ${PWD}/badfile_copy.txt

for ((n_month=${month}; n_month<=${monthEnd}; n_month++));
do
  dayinmonth=$(cal $n_month $year | egrep -v [a-z] | wc -w)
#  echo ${dayinmonth} days in year ${year} month ${n_month}

  for ((nday=1; nday<=${dayinmonth}; nday++));
#  for ((nday=5; nday<=10; nday++));
  do
    id=$(printf "%04d%02d%02d" $year $n_month $nday)   #add leading zero2. 0 means leading zero, 2 means 2 digits

#    # check if results exists (-e for file)
#    if [ -e ${output_scrt}${id}/*.nc ]; then
#      cp -r ${output_scrt}${id}/*.nc ${output_proj} 
#    else
#      echo ${id} >> ${PWD}/badfile_copy.txt
#    fi
    if [ ! -e ${output_proj}/*${id}*.nc ]; then
#      cp -r ${output_scrt}${id}/*.nc ${output_proj} 
#      if  [ ! -e ${output_scrt}${id}/*.nc ]; then
        echo ${id} >> ${PWD}/badfile_copy.txt
#      fi
    fi

  done
done

