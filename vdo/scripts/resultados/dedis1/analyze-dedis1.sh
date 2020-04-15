#!/bin/bash

declare -i y=0


echo "Date	Hour	Benchmark	Dataset	Test	Access	Process	Iteration	Latency	Throughput	Operations" > /tmp/awkDEDIS1

for f in dedisbench1/*
do
	awk -f ~/repositorios/tese/vdo/scripts/resultados/dedis1/dedis1.awk $f >> /tmp/awkDEDIS1
done

python3 ~/repositorios/tese/vdo/scripts/resultados/dedis1/merge-rows.py /tmp/awkDEDIS1