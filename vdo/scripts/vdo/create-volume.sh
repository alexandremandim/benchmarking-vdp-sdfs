#!/bin/bash

VOLUME_NAME=$1

create_volume()
{
	vdo create --name=$VOLUME_NAME --device=/dev/sda6 --vdoLogicalSize=96G --sparseIndex=enabled --writePolicy=sync --force
}

if test -z "$VOLUME_NAME" 
then
      echo "Missing volume name!"
else
      create_volume
fi