#! /bin/sh

#Author: Chu Viet Hung vhc@tu-clausthal.de

if [ -z $1 ]; then
	host=localhost
else
	host=$1
fi

if [ -z $2 ];then
	port=1097
else
	port=$2
fi

java -Xss20000k -jar cowMonitor.jar -rmihost $host -rmiport $port 
