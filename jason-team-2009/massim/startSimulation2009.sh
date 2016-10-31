#! /bin/sh
#Author: Chu Viet Hung vhc@tu-clausthal.de

#Cleaning old run logs on backup
rm -rf backup/*

if [ -z $1 ]; then
  conf=conf/serverconfig80x80_20agents.xml
  
else
  conf=$1
fi
myip=`/sbin/ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
sleep 1
echo "Launching Server"
echo $conf
java  -Xss20000k -Djava.rmi.server.hostname=$myip -jar Simulation2009.jar --conf $conf
