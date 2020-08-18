#!/bin/bash

# Script para testar VDO
# Antes de correr este script verificar que o queue scheduler == noop p/ SSD's
# ./script.sh 

# LOGS
log_run=""
dstat_file_name=""
iostat_file_name=""
vdostats_file_name=""

dstat_pid=""
iostat_pid=""
vdo_stats_pid=""
infinitevdo_stats_file_name=""
vdo_volume_name="volume-name"
input_file=""
benchmark=""
dataset=""
test_type=""
access_type=""
process_number=""
run_number=""
run_ID=""
filesize="60000" #em MB
blocksize="4096" #em bytes
log_files_list=""


generate_all_input_files(){
	# Total de 384 runs
	for benchmark in dedisbench1 #dedisbench2
	do
		for dataset in dataset1 dataset2
		do
			for test_type in w #r w
			do
				for access_type in sequencial #uniform hotspot
				do
					# Fio doesnt have hotpost type of access
					if [ $access_type = "hotspot" -a $benchmark = "fio" ]
					then
						break
					else
						for process_number in 1 4
						do
							generate_input_file
						done
					fi
				done
			done
		done
	done
}

generate_input_file(){

	file_name="$dataset"_"$access_type"_"$process_number"_"$test_type"

	if [ "$benchmark" = "dedisbench1" ] 
	then
		input_file="./inputs/dedisbench1/$file_name"
		touch $input_file
		echo "[execution]" > $input_file
		echo "distfile=datasets/dedis1/$dataset" >> $input_file
		if [ "$access_type" = "sequencial" ] 
		then
			echo "access_type=0" >> $input_file
		elif [ "$access_type" = "uniform" ]
		then
			echo "access_type=1" >> $input_file
		else
			echo "access_type=2" >> $input_file
		fi
		echo "nprocs=$process_number" >> $input_file
		echo "filesize=$filesize" >> $input_file
		echo "blocksize=$blocksize" >> $input_file
		echo "sync=1" >> $input_file
		if [ "$test_type" = "w" ]
		then
			echo "populate=0" >> $input_file
		else
			echo "populate=1" >> $input_file
		fi
		#echo "rawdevice=/dev/mapper/$vdo_volume_name" >> $input_file

		echo "[results]" >> $input_file
		echo "tempfilespath=/mnt/sda6/" >> $input_file

		echo "[structural]" >> $input_file		
		echo "cleantemp=0" >> $input_file


	elif [ "$benchmark" = "dedisbench2" ]
	then
		input_file="./inputs/dedisbench2/$file_name"
		touch $input_file
		echo "[execution]" > $input_file
		echo "distfile=datasets/dedis2/$dataset" >> $input_file
		#echo "distfile=datasets/dedis2/fio_${dataset}_sequential.txt" >> $input_file
		if [ "$access_type" = "sequencial" ] 
		then
			echo "access_type=0" >> $input_file
		elif [ "$access_type" = "uniform" ]
		then
			echo "access_type=1" >> $input_file
		else
			echo "access_type=2" >> $input_file
		fi
		echo "nprocs=$process_number" >> $input_file

		echo "filesize=$filesize" >> $input_file
		echo "blocksize=$blocksize" >> $input_file
		echo "sync=1" >> $input_file
		if [ "$test_type" = "w" ]
		then
			echo "populate=0" >> $input_file
		else
			echo "populate=1" >> $input_file
		fi
		echo "rawdevice=/dev/mapper/$vdo_volume_name" >> $input_file
		
		# Compressao baseada nos datasets
		if [ "$dataset" = "dataset1" ]
		then
			echo "compression_to_achieve = 5" >> $input_file
		fi
		if [ "$dataset" = "dataset2" ]
		then
			echo "compression_to_achieve = 80" >> $input_file
		fi

		echo "percentage_analyze = 5" >> $input_file

		echo "[results]" >> $input_file

		echo "#tempfilespath=/home/alex/Desktop/bug/" >> $input_file


		echo "[structural]" >> $input_file
		echo "cleantemp=0" >> $input_file

	else
		echo "generate_input_file: no benchmark" >> $log_run
	fi
}

main(){
	mkdir -p ./inputs/dedisbench1/
	#mkdir -p ./inputs/dedisbench2/
	generate_all_input_files
}

main