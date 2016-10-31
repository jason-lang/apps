###############################################################
#!/bin/sh                                                     #
###############################################################
# Multi-Agent Programming Contest 2008                        #
#                                                             # 
# Support package massim-Server                               #
#   This script runs the massim server locally  with the      #
#   default parameters. It also runs at first the rmiregistry #
#   where the server and clients (servermonitor,webinterface) #
#   must connect to.                                          #
#                                                             #
# For the details on the contest, check the Contest website:  #
#   http://cig.in.tu-clausthal.de/agentcontest2008/           #
#                                                             #
# Organizers:                                                 #
#    J. Dix, M. Dastani, P. Novak, T.M. Behrens               #
###############################################################

name=localhost

clear

echo "Launching RMI Registry"
rmiregistry 1099 &
sleep 1

echo "Launching Server"
java -Djava.rmi.server.hostname=$name -jar lib/massimserver.jar --conf conf/serverconfig.xml

echo "Killall RMI Registry"
killall rmiregistry -w