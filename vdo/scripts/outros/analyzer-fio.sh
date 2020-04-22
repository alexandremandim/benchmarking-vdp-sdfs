#!/bin/bash

# foi criada um fs: sudo mkfs.ext4 /dev/sda6
# montado em /mnt/analyzer/

mkdir -p resultadosAnalyzer
mkdir -p resultadosFio

for dataset in dataset2 dataset1
do
	for access_type in sequencial
	do
		echo "Running fio ${dataset} - ${access_type}"
		fio ./inputs/${dataset}_${access_type} > "resultadosFio/fio_${dataset}_${access_type}"
		echo "Running analyzer"
		python3 ./pythonAnalyzer/analyze.py -a /mnt/analyzer/
		echo "Moving analyzer results"
		mv resultado.txt "resultadosAnalyzer/fio_${dataset}_${access_type}.txt"
		mv resultado-dedis.txt "resultadosAnalyzer/fio_${dataset}_${access_type}-dedis.txt"
		mv resultado_segmentado.txt "resultadosAnalyzer/fio_${dataset}_${access_type}_segmentado.txt"
		echo "Deleting files"
		rm -r /mnt/analyzer/*

	done
done
