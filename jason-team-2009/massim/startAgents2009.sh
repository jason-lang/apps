#! /bin/bash
#echo "Please specifiy the hostname of the server:"
#read HOST
export HOST=localhost

#echo "Please set the number of agents:"
#read NUMBER_AGENT
export NUMBER_AGENT=10
i=1

for ((i=1; i<=$NUMBER_AGENT ; i++)); do
#for i in `jot 20`; do
#    echo $i
	java -jar DemoAgent.jar -username $i -password 1 -host $HOST &  
#	sleep 1
done
