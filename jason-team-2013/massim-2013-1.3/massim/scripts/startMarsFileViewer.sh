#! /bin/bash

source header.sh

if [ -z $1 ]; then
	echo "Please specify a directory."
	echo "Usage: sh startMarsFileViewer.sh directory"
        exit 1
else
	directory=$1
fi

java -Xss20000k -cp $package massim.competition2013.monitor.GraphFileViewer -dir $directory 
