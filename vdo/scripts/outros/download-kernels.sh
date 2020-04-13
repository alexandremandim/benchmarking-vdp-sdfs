#!/bin/bash

mkdir -p ~/Desktop/Temp/
mkdir -p ~/Desktop/Temp/desc

cd ~/Desktop/Temp

for i in {0..39}; do
echo $i
    wget  https://mirrors.edge.kernel.org/pub/linux/kernel/v2.6/linux-2.6.$i.tar.bz2
    tar -xf linux-2.6.$i.tar.bz2 -C ./desc
done

python3 /home/alex/repositorios/pythonAnalyzer/analyze.py -a ~/Desktop/Temp/desc

/home/alex/repositorios/dedisbench/DEDISgen -f -p/home/alex/Desktop/Temp/desc/ -o/home/alex/Desktop/Temp/dedisgen
