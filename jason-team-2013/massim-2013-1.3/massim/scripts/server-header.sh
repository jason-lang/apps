#!/bin/bash
# DO NOT CHANGE ANYTHING IN HERE!
# INSTEAD OVERRIDE THE VARIABLE IN THE CORRESPONDING START SCRIPT!

# initialize certain values
source header.sh
date=`date +%Y-%m-%d_%H:%M`
year=`date +%Y`
day=`date +%A`
webappPath=/home/massim/www/webapps/massim
webapp=$webappPath/WEB-INF/classes
hostname=`hostname -f`
conf=conf/

function runServer {
# test if script runs in a screen else start a new one (if the command screen exists)
if [ -z "$STY" -a -n $( type -P screen ) ]
then
	echo "Start new screen"
	screen ./$(basename $0)
else
	if [ $resultPage != false ]
	then
		# move old result page
		mv $webappPath/index.html $webappPath/moved-at-$date.html
	fi

	# create folder for log files
	mkdir -p backup

	count=0
	for i in $configs
	do
	  if [ -f $i ]
	  then
	    echo $count: $i
	    count=`expr $count + 1`
	  fi
	done
	echo "Please choose a number and then press enter:"

	read number

	count=0
	for i in $configs
	do
	  if [ -f $i ]
	  then
	    if [ $number -eq $count ]
	    then
	      conf=$i
	    fi
	    count=`expr $count + 1`
	  fi
	done

	echo "Starting server: $conf"
	repeat=true;
	while ($repeat)
	do
		java -ea -Dcom.sun.management.jmxremote -Xss2000k -Xmx600M  -DentityExpansionLimit=1000000 -DelementAttributeLimit=1000000 -Djava.rmi.server.hostname=$hostname -jar $package --conf $conf
		if [ $resultPage != false ]
		then
			# create results page
			java -cp $webapp massim.webclient.CreateResultsPage $webappPath/xslt/createResultsHTML.xslt backup/*_report.xml
			mv Tournament.html $webappPath/index.html
		fi

		# make backup of the report
		cd backup
		for i in $( ls *_report.xml )
		do
			mv $i $date-$hostname-result.xml
		done
		cd ..	
		if [ $testServerMode != true ]
		then
			repeat=false
		else
			echo "Restarting server in 10 seconds."
			sleep 10
		fi
	done	
fi
}
