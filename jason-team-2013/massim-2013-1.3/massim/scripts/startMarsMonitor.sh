#!/bin/bash

source header.sh

if [ -z $1 ]; then
	host=localhost
else
	host=$1
fi

if [ -z $2 ];then
	port=1099
else
	port=$2
fi

java -Xss20000k -cp $package massim.competition2013.monitor.GraphMonitor -rmihost $host -rmiport $port -savexmls 
