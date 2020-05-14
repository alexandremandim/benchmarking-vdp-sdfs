#!/bin/bash

csv="vdo_stats.csv"
flag="0"

for pasta in $(ls -Rl | grep -o '\./.*vdo_stats')
do 
    echo "Processing ${pasta}"
    cd $pasta

    for f in $(ls)
    do
    if [ "$flag" == "0" ]; then
        printf "benchmark\tdataset\ttest\taccess\tprocess\titeration\t" > "../../${csv}"
        awk -F '(\ +:)|(\ ){2}' 'NR > 1 {printf("%s\t", $1);} END{printf "\n"}' $f >> "../../${csv}"
        flag="1"
    fi
        awk -f ~/repositorios/tese/vdo/scripts/resultados/awk/vdostats-csv.awk $f >> "../../${csv}"
    done
    cd ../..
done