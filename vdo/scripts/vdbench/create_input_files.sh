#!/bin/bash
# Script para criar os job files para o FIO

vdoVolumeName="/dev/mapper/volume-name"
runTime=20
size=60
blockSize=4k

general()
{
    echo "#General" > $input_file

    if [ "$dataset" = "dataset1" ] 
    then
        echo "compratio=6" >> $input_file 
        echo "dedupratio=" >> $input_file 
        echo "dedupunit=" >> $input_file 
        echo "dedupsets=" >> $input_file 
        echo "deduphotsets=" >> $input_file 
        echo "dedupflipflop=" >> $input_file 
    elif [ "$dataset" = "dataset2" ]
    then
        echo "compratio=74"   >> $input_file 
        echo "dedupratio=" >> $input_file 
        echo "dedupunit=" >> $input_file 
        echo "dedupsets=" >> $input_file 
        echo "deduphotsets=" >> $input_file 
        echo "dedupflipflop=" >> $input_file 
    fi   
}

sd()
{
    echo "#SD" >> $input_file
    echo "sd=sd1" >> $input_file 
    echo "lun=${vdoVolumeName}" >> $input_file
    echo "size=${size}" >> $input_file
    echo "openflags=o_direct" >> $input_file

    if [ "$process_number" = "4"  ]
    then
        let size4=size/$process_number
        echo "threads=4" >> $input_file
        echo "" >> $input_file
    else
        echo "threads=1" >> $input_file
    fi
}

wd()
{
    echo "#WD" >> $input_file
    echo "wd=wd1" >> $input_file
    echo "sd=sd1" >> $input_file
    # Paralelismo
    if [ "$process_number" = "4"  ]
    then
        echo "streams=4" >> $input_file
    fi
    # Tipo de teste (Read ou write)
    if [ "$test_type" = "w" ]
    then
        echo "rdpct=0" >> $input_file
    elif [ "$test_type" = "r" ]
    then
        echo "rdpct=100" >> $input_file
    fi
    # Tipo de acesso
    if [ "$access_type" = "sequencial" ]
    then
        echo "seekpct=sequential" >> $input_file
    elif [ "$access_type" = "uniform" ]
    then
        echo "seekpct=random" >> $input_file
    fi
}

rd()
{
    echo "#RD" >> $input_file
    echo "rd=rd1" >> $input_file
    echo "wd=wd1" >> $input_file
    let timeSec=$runTime*60
    echo "elapsed=${timeSec}" >> $input_file
    echo "maxdata=${size}g" >> $input_file
}

# Ordem : General, (HD, RG), SD, WD, RD
generate_input_file()
{
    general
    sd
    wd
    rd
}

main(){
    # Voltar a criar a pasta e ficheiro
    mkdir -p ../../inputs/vdbench/
    rm -f ../../inputs/vdbench/*

    for dataset in dataset1 dataset2
    do
        for test_type in r w
        do
            for access_type in sequencial uniform
            do
                for process_number in 1 4
                do
                    # Nome do ficheiro (baseado no dataset, tipo de acesso, teste e nr processos)
                    file_name="$dataset"_"$access_type"_"$process_number"_"$test_type.ini"
                    input_file="../../inputs/vdbench/$file_name"
                    touch $input_file
                    # Popular ficheiro
                    generate_input_file
                done
            done
        done
    done
}

main
    echo "" >> $input_file