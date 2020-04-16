#!/bin/bash

#D1
dedis1()
{
	echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	IOPS	IO(GiB)" > /tmp/awkDEDIS1

	for f in dedisbench1*/dedisbench1/*
	do
		awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/dedis1.awk $f >> /tmp/awkDEDIS1
	done

	python3 ~/repositorios/tese/vdo/scripts/resultados/merge-rows.py /tmp/awkDEDIS1 DEDIS1
}

#D2
dedis2()
{
	echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	IOPS	IO(GiB)" > /tmp/awkDEDIS2

	for f in dedisbench2*/dedisbench2/*
	do
		awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/dedis2.awk $f >> /tmp/awkDEDIS2
	done

	python3 ~/repositorios/tese/vdo/scripts/resultados/merge-rows.py /tmp/awkDEDIS2 DEDIS2
}

#FIO
fio(){

	echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	IOPS	IO(GiB)" > /tmp/awkFIO

	for f in fio*/fio/*
	do
		awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/fio.awk $f >> /tmp/awkFIO
	done

	python3 ~/repositorios/tese/vdo/scripts/resultados/merge-rows.py /tmp/awkFIO FIO
}

vdbench(){
	echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	IOPS	IO(GiB)" > /tmp/awkVDBENCH

	for f in vdbench*/vdbench/*vdbench*/
	do
		GiB=$(awk '/[0-9]+\.[0-9]+\ </ {gsub(/\,/, "", $4); operations += $4} END {printf ((operations*4096)/(1024*1024*1024))}' "${f}histogram.html")
		awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/vdbench.awk "${f}totals.html" >> /tmp/awkVDBENCH
		echo $GiB >> /tmp/awkVDBENCH
	done

	python3 ~/repositorios/tese/vdo/scripts/resultados/merge-rows.py /tmp/awkVDBENCH VDBENCH
}

dedis1
dedis2
fio
vdbench