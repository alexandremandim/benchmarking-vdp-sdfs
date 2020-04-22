#!/bin/bash

mkdir -p resultadosAnalyzer
mkdir -p resultadosVDbench

for dataset in dataset1 dataset2
do
	for access_type in sequencial
	do
		echo "Running vdbench ${dataset} - ${access_type}"
		~/vdbench/vdbench -f ~/inputs/${dataset}_${access_type} -o "/home/gsd/resultadosVDbench/${dataset}_${access_type}/"
		echo "Running analyzer"
		python3 ./pythonAnalyzer/analyze.py -a /mnt/analyzer/ > "resultadosAnalyzer/vdbench_${dataset}_${access_type}-log"
		echo "Moving analyzer results"
		mv resultado.txt "resultadosAnalyzer/vdbench_${dataset}_${access_type}.txt"
		mv resultado-dedis.txt "resultadosAnalyzer/vdbench_${dataset}_${access_type}-dedis.txt"
		mv resultado_segmentado.txt "resultadosAnalyzer/vdbench_${dataset}_${access_type}_segmentado.txt"
		echo "Deleting files"
		rm -r /mnt/analyzer/*

	done
done
