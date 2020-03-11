#!/bin/bash

# Script para testar VDO
# Antes de correr este script verificar que o queue scheduler == noop p/ SSD's
# ./script.sh 

# LOGS
log_run=""
dstat_file_name=""
iostat_file_name=""

dstat_pid=""
iostat_pid=""
vdo_stats_pid=""
vdo_volume_name="volume-name"
input_file=""
benchmark=""
dataset=""
test_type=""
access_type=""
process_number=""
run_number=""
run_ID=""

initial_state()
{

	device_name="/dev/sda6"
	vdo_logical_size="96G"

	echo "initial_state: trimming" >> $log_run
	sudo blkdiscard /dev/sda6 

	echo "initial_state: create volume $vdo_volume_name" >> $log_run
	./scripts/vdo/create-volume.sh $vdo_volume_name >> $log_run
}

start_monitoring()
{
 	dstat=$1
	iostat=$2
	vdo_stats=$3

	if [ "$dstat" = true ]
	then
		dstat_file_name="./logs/dstat/dstat_$run_ID.csv"
		dstat -cm --output $dstat_file_name > /dev/null 2>&1 &
		dstat_pid=$!
		echo "start_monitoring: Started dstat with pid $dstat_pid" >> $log_run 
	fi

	if [ "$iostat" = true ] 
	then
		iostat_file_name="./logs/iostat/iostat_$run_ID.txt"
		iostat -d 2 > $iostat_file_name 2>>$log_run &
		iostat_pid=$!
		echo "start_monitoring: Started iostat with pid $iostat_pid" >> $log_run 
	fi
}

benchmark()
{
	# Guardar estado inicial do volume VDO
	# VDO Stats Inicial
	vdostats --verbose >> "./logs/vdo_stats/"$run_ID"_vdo_stats_1"

	# Sistema de benchmarking
	if [ "$benchmark" = "vdbench" ]
	then
		echo "benchmark: starting vdbench" >> $log_run
		input_file="./inputs/vdbench/${dataset}"_"${access_type}"_"${process_number}"_"${test_type}.ini"
		~/vdbench/vdbench -f $input_file -o "./logs/vdbench/${dataset}"_"${access_type}"_"${process_number}"_"${test_type}/"
	else
		echo "benchmark: no benchmark started" >> $log_run
	fi

	# Guardar estado final do volume VDO
	# VDO Stats Final
	vdostats --verbose >> "./logs/vdo_stats/"$run_ID"_vdo_stats_2"
}

stop_monitoring()
{
	if [ "$dstat_pid" != "" ]
	then
		kill $dstat_pid && echo "stop_monitoring: dstat" >> $log_run
		dstat_pid=""
	fi
	if [ "$iostat_pid" != "" ]
	then
		kill $iostat_pid && echo "stop_monitoring: iostat" >> $log_run
		iostat_pid=""
	fi
	if [ "$vdo_stats_pid" != "" ]
	then
		kill $vdo_stats_pid && echo "stop_monitoring: vdostats" >> $log_run
		vdo_stats_pid=""
	fi
}

close_the_door()
{
	echo "close_the_door: removing volume" >> $log_run
	./scripts/vdo/remove-volume.sh $vdo_volume_name >> $log_run
	echo "Sleeping 5 minutes and sending logs" >> $log_run
	sleep 300
}

send_logs()
{
	sshpass -p "123456" scp -r logs/ gsd@192.168.112.67:/home/gsd/logs_vdo/"${benchmark}_"$(date "+%Y-%m-%d_%H-%M-%S")
}

run_all_tests()
{
	echo "main: Starting FIO tests"
	
	for benchmark in vdbench
	do
		for dataset in dataset1 dataset2
		do
			for test_type in r w
			do
				for access_type in sequencial uniform poisson
				do
					for process_number in 1 4
					do
						for run_number in 1 2 3 4
						do
							single_run
						done
					done
				done
			done
		done
	done
	echo "main: End of the tests"	
}

single_run()
{
	# ID que identifica cada RUN
	#run_ID="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
	run_ID="$(date +"%Y-%m-%d_%H-%M-%S")"

	run_ID=$run_ID"_"$benchmark"_"$dataset"_"$test_type"_"$access_type"_"$process_number"_"$run_number

	# Variavel para onde vai ser rederecionado todos os logs sobre a RUN
	log_run="./logs/runs/log_$run_ID.txt"
	echo "RUN: $run_ID"
	
	initial_state

	if [ $run_number = 4 ]
	then
		start_monitoring true true true
	else
		# Só monitorizo o iostat na 4ª run
		start_monitoring true false false
	fi

	benchmark
	stop_monitoring
	close_the_door
}

main()
{
	mkdir -p ./logs/vdbench/
	mkdir -p ./logs/dstat/
	mkdir -p ./logs/iostat/
	mkdir -p ./logs/vdo_stats/
	mkdir -p ./logs/runs/
	cd ./logs/
	run_all_tests
	send_logs
}

main