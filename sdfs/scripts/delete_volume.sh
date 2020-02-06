#!/bin/bash

if [ "$1" != "" ]; then
	umount /media/$1
	rm -rf /opt/sdfs/volumes/$1/
	rm /var/log/sdfs/$1*
	rm /etc/sdfs/$1*
	rm -rf /media/$1
else
        echo "Missing volume name"
fi

