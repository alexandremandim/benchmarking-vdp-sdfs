#!/bin/bash
# Script para criar os job files para o FIO

vdoVolumeName="/mnt/sda6"
runTime=20 # in minutes
size=60

general()
{
    echo "#General" > $input_file

    if [ "$dataset" = "dataset1" ] 
    then
        echo "dedupratio=1.52" >> $input_file 
        echo "dedupunit=4k" >> $input_file 
        echo "dedupsets=17%" >> $input_file 
        echo "compratio=1.0638" >> $input_file # 6%
    elif [ "$dataset" = "dataset2" ]
    then
        echo "dedupratio=2.56" >> $input_file 
        echo "dedupunit=4k" >> $input_file 
        echo "dedupsets=17%" >> $input_file 
        echo "compratio=3.846"   >> $input_file # 74%
    fi   
}

sd()
{
    echo "#FSD" >> $input_file
    echo "fsd=sd1" >> $input_file 
    echo "width=1" >> $input_file 
    echo "depth=1" >> $input_file 
    echo "files=1" >> $input_file 
    echo "anchor=${vdoVolumeName}" >> $input_file
    echo "sizes=${size}g" >> $input_file
    echo "totalsize=${size}g" >> $input_file
    #echo "openflags=o_direct" >> $input_file

    if [ "$process_number" = "4"  ]
    then
        echo "threads=4" >> $input_file
    else
        echo "threads=1" >> $input_file
    fi
}

wd()
{
    echo "#WD" >> $input_file
    echo "fwd=wd1" >> $input_file
    echo "fsd=sd1" >> $input_file
    echo "fileio=sequential" >> $input_file
    echo "xfersizes=4k" >> $input_file
    echo "threads=1" >> $input_file

    # Tipo de teste (Read ou write)
    if [ "$test_type" = "w" ]
    then
        echo "rdpct=0" >> $input_file
    elif [ "$test_type" = "r" ]
    then
        echo "rdpct=100" >> $input_file
    fi
    
}

rd()
{
    echo "#RD" >> $input_file
    echo "rd=rd1" >> $input_file
    echo "fwd=wd1" >> $input_file
    echo "fwdrate=max" >> $input_file
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

generate_populate_file()
{
    general

    echo "#SD" >> $input_file
    echo "sd=sd1" >> $input_file 
    echo "lun=${vdoVolumeName}" >> $input_file
    echo "size=${size}g" >> $input_file
    echo "openflags=o_direct" >> $input_file
    echo "threads=1" >> $input_file

    echo "#WD" >> $input_file
    echo "wd=wd1" >> $input_file
    echo "sd=sd1" >> $input_file
    echo "xfersize=4k" >> $input_file

    echo "rdpct=0" >> $input_file
    echo "seekpct=sequential" >> $input_file

    echo "#RD" >> $input_file
    echo "rd=rd1" >> $input_file
    echo "wd=wd1" >> $input_file
    echo "iorate=max" >> $input_file
    echo "elapsed=2h" >> $input_file
    echo "maxdata=${size}g" >> $input_file
}

main(){
    # Voltar a criar a pasta e ficheiro
    mkdir -p ../../inputs/vdbench/
    rm -f ../../inputs/vdbench/*

    for dataset in dataset1 dataset2
    do
        input_file="../../inputs/vdbench/populate_${dataset}.ini"
        #generate_populate_file
        for test_type in w #r w
        do
            for access_type in sequencial #uniform poisson
            do
                for process_number in 1 #4
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