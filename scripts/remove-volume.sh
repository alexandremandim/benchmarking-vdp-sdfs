#!/bin/bash

VOLUME_NAME=$1

remove_volume()
{
	vdo remove --name=$VOLUME_NAME
}

if test -z "$VOLUME_NAME" 
then
      echo "Missing volume name!"
else
      remove_volume
fi