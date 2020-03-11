#!/bin/bash
# Script para criar os job files para o FIO

vdoVolumeName="/dev/mapper/volume-name"
runTime=20 # in minutes
size=60

general()
{
    echo "#General" > $input_file

    if [ "$dataset" = "dataset1" ] 
    then
        echo "dedupratio=2.9" >> $input_file 
        echo "dedupunit=4k" >> $input_file 
        echo "dedupsets=17%" >> $input_file 
        echo "compratio=6" >> $input_file 
    elif [ "$dataset" = "dataset2" ]
    then
        echo "dedupratio=1.64" >> $input_file 
        echo "dedupunit=4k" >> $input_file 
        echo "dedupsets=17%" >> $input_file 
        echo "compratio=74"   >> $input_file 
    fi   
}

sd()
{
    echo "#SD" >> $input_file
    echo "sd=sd1" >> $input_file 
    echo "lun=${vdoVolumeName}" >> $input_file
    echo "size=${size}g" >> $input_file
    echo "openflags=o_direct" >> $input_file

    if [ "$process_number" = "4"  ]
    then
        let size4=size/$process_number
        echo "threads=4" >> $input_file
    else
        echo "threads=1" >> $input_file
    fi
}

wd()
{
    echo "#WD" >> $input_file
    echo "wd=wd1" >> $input_file
    echo "sd=sd1" >> $input_file
    echo "xfersize=4k" >> $input_file

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
        if [ "$process_number" = "4"  ]
        then
            echo "streams=4" >> $input_file
        fi
    elif [ "$access_type" = "uniform" ]
    then
        echo "seekpct=random" >> $input_file
    elif [ "$access_type" = "poisson" ]
    then
        echo "seekpct=(poisson,3)" >> $input_file
    fi
}

rd()
{
    echo "#RD" >> $input_file
    echo "rd=rd1" >> $input_file
    echo "wd=wd1" >> $input_file
    echo "iorate=max" >> $input_file
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
            for access_type in sequencial uniform poisson
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