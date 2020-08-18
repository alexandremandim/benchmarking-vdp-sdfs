#!/bin/bash
# Script para criar os job files para o FIO

# Variáveis globais
vdoVolumeName="/mnt/sda6"
runTime=20
size=60
zipf=1.2
ioEngine="libaio"
blockSize=4k

# Funções
generate_input_file(){
    echo "; -- start job file --" > $input_file
    echo "[global]" >> $input_file
    echo "runtime=${runTime}m" >> $input_file # Corre durante 20 minutos

    echo "filename=${vdoVolumeName}" >> $input_file   # Especifica o caminho
    echo "direct=1" >> $input_file #O_DIRECT
    echo "ioengine=${ioEngine}" >> $input_file
    echo "blocksize=${blockSize}" >> $input_file
    echo "iodepth=1" >> $input_file

    #
    if [ "$process_number" = "4"  ]
    then
        let size4=size/$process_number
        echo "size=${size4}g" >> $input_file
        echo "offset_increment=${size4}g" >> $input_file
        echo "numjobs=4" >> $input_file
    else
        echo "size=${size}g" >> $input_file
    fi

    # Tipo de acesso (read,write)
    # Tipo de teste (sequencial,uniform,zipf)
    if [ "$test_type" = "w" -a "$access_type" = "sequencial" ]
    then
        echo "readwrite=write" >> $input_file
    elif [ "$test_type" = "w" -a "$access_type" = "uniform" ]
    then
        echo "readwrite=randwrite" >> $input_file
    elif [ "$test_type" = "r" -a "$access_type" = "sequencial" ]
    then
        echo "readwrite=read" >> $input_file
    elif [ "$test_type" = "r" -a "$access_type" = "uniform" ]
    then
        echo "readwrite=randread" >> $input_file
    elif [ "$test_type" = "w" -a "$access_type" = "zipf" ]
    then
        echo "readwrite=randwrite" >> $input_file
        echo "random_distribution=zipf:${zipf}" >> $input_file
    elif [ "$test_type" = "r" -a "$access_type" = "zipf" ]
    then
        echo "readwrite=randread" >> $input_file
        echo "random_distribution=zipf:${zipf}" >> $input_file
    fi
    # Benchmark (valores de compressao e dedup)
    if [ "$dataset" = "dataset1" ] 
    then
        echo "buffer_compress_percentage=6" >> $input_file
        echo "dedupe_percentage=34" >> $input_file 
    elif [ "$dataset" = "dataset2" ]
    then
        echo "buffer_compress_percentage=74" >> $input_file
        echo "dedupe_percentage=61" >> $input_file 
    fi
    echo "[proc]" >> $input_file
    echo "; -- end job file --" >> $input_file
}

generate_populate_job(){
    echo "; -- start populate job file --" > $input_file
    echo "[global]" >> $input_file

    echo "filename=${vdoVolumeName}" >> $input_file   # Especifica o caminho
    echo "direct=1" >> $input_file #O_DIRECT
    echo "ioengine=${ioEngine}" >> $input_file
    echo "blocksize=${blockSize}" >> $input_file
    echo "iodepth=1" >> $input_file
    echo "size=${size}g" >> $input_file
    echo "readwrite=write" >> $input_file

    # Benchmark (valores de compressao e dedup)
    if [ "$dataset" = "dataset1" ] 
    then
        echo "buffer_compress_percentage=6" >> $input_file
        echo "dedupe_percentage=34" >> $input_file 
    elif [ "$dataset" = "dataset2" ]
    then
        echo "buffer_compress_percentage=74" >> $input_file
        echo "dedupe_percentage=61" >> $input_file 
    fi
    echo "[proc]" >> $input_file
    echo "; -- end job file --" >> $input_file
}

main(){
    
    # Voltar a criar a pasta e ficheiro
    mkdir -p ./inputs/fio/

    for dataset in dataset1 dataset2
    do
        input_file="./inputs/fio/populate_${dataset}.ini"
        #generate_populate_job
        for test_type in r w
        do
            for access_type in sequencial #uniform zipf
            do
                for process_number in 1 #4
                do
                    # Nome do ficheiro (baseado no dataset, tipo de acesso, teste e nr processos)
                    file_name="$dataset"_"$access_type"_"$process_number"_"$test_type.ini"
                    input_file="./inputs/fio/$file_name"
                    touch $input_file
                    # Popular ficheiro
                    generate_input_file
                done
            done
        done
    done
}
main