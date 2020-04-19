#!/bin/bash

# criar a funcao p escrever os 4 valores
# alterar awk's p nao escreverem os \n
# escrever \n em toda iteracao

outputFile=""

vdoStatsAnalyzerVDBench()
{
	file="${1}totals.html"

	dir1=$(awk 'NR==1 {split(FILENAME,a,"\/"); print a[1]}' ${file})
	dir2="/vdo_stats/"
	filename=$(awk 'NR==1 {split(FILENAME,a,"\/"); print a[3]}' ${file})

	fn="${dir1}${dir2}${filename}_vdo_stats_2"

	awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/vdo_stats.awk $fn >> $outputFile
}

vdoStatsAnalyzer()
{
	file=$1
	dir1=$(awk 'NR==1 {split(FILENAME,a,"\/"); print a[1]}' ${file})
	dir2="/vdo_stats/"
	filename=$(awk 'NR==1 {split(FILENAME,a,"\/"); print a[3]}' ${file})

	fn="${dir1}${dir2}${filename}_vdo_stats_2"

	awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/vdo_stats.awk $fn >> $outputFile
}

#D1
dedis1()
{
	outputFile="/tmp/awkDEDIS1"
	echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	IOPS	IO(GiB)	LogBlkUsed	PhysBlkUsed	CompressFrag	CompressBlk" > $outputFile

	for f in dedisbench1*/dedisbench1/*
	do
		awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/dedis1.awk $f >> $outputFile
		vdoStatsAnalyzer $f
	done

	python3 ~/repositorios/tese/vdo/scripts/resultados/merge-rows.py /tmp/awkDEDIS1 DEDIS1 > results.csv
}

#D2
dedis2()
{
	outputFile="/tmp/awkDEDIS2"
	echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	IOPS	IO(GiB)	LogBlkUsed	PhysBlkUsed	CompressFrag	CompressBlk" > $outputFile

	for f in dedisbench2*/dedisbench2/*
	do
		awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/dedis2.awk $f >> $outputFile
		vdoStatsAnalyzer $f
		
	done

	python3 ~/repositorios/tese/vdo/scripts/resultados/merge-rows.py /tmp/awkDEDIS2 DEDIS2 >> results.csv
}

#FIO
fio()
{
	outputFile="/tmp/awkFIO"
	echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	IOPS	IO(GiB)	LogBlkUsed	PhysBlkUsed	CompressFrag	CompressBlk" > $outputFile

	for f in fio*/fio/*
	do
		awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/fio.awk $f >> $outputFile
		vdoStatsAnalyzer $f
		
	done

	python3 ~/repositorios/tese/vdo/scripts/resultados/merge-rows.py /tmp/awkFIO FIO >> results.csv
}

vdbench()
{
	outputFile="/tmp/awkVDBENCH"
	echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	IOPS	IO(GiB)	LogBlkUsed	PhysBlkUsed	CompressFrag	CompressBlk" > $outputFile

	for f in vdbench*/vdbench/*vdbench*/
	do
		GiB=$(awk '/[0-9]+\.[0-9]+\ </ {gsub(/\,/, "", $4); operations += $4} END {printf ((operations*4096)/(1024*1024*1024))}' "${f}histogram.html")
		awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/vdbench.awk "${f}totals.html" >> $outputFile
		printf $GiB >> $outputFile
		vdoStatsAnalyzerVDBench $f
	done

	python3 ~/repositorios/tese/vdo/scripts/resultados/merge-rows.py /tmp/awkVDBENCH VDBENCH >> results.csv
}

dedis1
dedis2
fio
vdbench