#!/bin/bash

output_dir=ping_ovs_output

# Ping data sizes
first=200
last=8800
step=200
sizes=(`seq $first $step $last`)
sizes+=(8952)

mkdir -p $output_dir
rm -rf ${output_dir}/*
echo -e "#ping_size\tno-rewriting\trewriting" > ${output_dir}/plotdata

for s in ${sizes[*]}
do
	# Perform single ping to load OVS caches
	ping6 n111_1 -c 1 > /dev/null

	# Perform experiment without rewriting
	output_file=${output_dir}/ping_s${s}_output
	sudo ping6 n111_1 -i 0.01 -c 100 -s $s > $output_file
	avg1=`tail -1 $output_file | gawk '{print $4}' | gawk 'BEGIN {FS = "/"}; {print $2}'`
	min1=`tail -1 $output_file | gawk '{print $4}' | gawk 'BEGIN {FS = "/"}; {print $1}'`
	max1=`tail -1 $output_file | gawk '{print $4}' | gawk 'BEGIN {FS = "/"}; {print $3}'`

	# Perform single ping to load OVS caches
	ping6 n111_r_1 -c 1 > /dev/null

	# Perform experiment with rewriting
	output_file=${output_dir}/ping_s${s}_r_output
	sudo ping6 n111_r_1 -i 0.01 -c 100 -s $s > $output_file
	avg2=`tail -1 $output_file | gawk '{print $4}' | gawk 'BEGIN {FS = "/"}; {print $2}'`
	min2=`tail -1 $output_file | gawk '{print $4}' | gawk 'BEGIN {FS = "/"}; {print $1}'`
	max2=`tail -1 $output_file | gawk '{print $4}' | gawk 'BEGIN {FS = "/"}; {print $3}'`

	echo -e "${s}\t${avg1}\t${avg2}" >> $output_dir/plotdata
done
