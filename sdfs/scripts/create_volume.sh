#!/bin/bash

if [ "$1" != "" ]; then
	sudo mkdir /media/$1
	sudo mkfs.sdfs --volume-name=$1 --volume-capacity=96GB --chunk-store-compress=true --io-chunk-size=4
	sudo mount.sdfs $1 /media/$1/
else
	echo "Missing volume name"
fi

