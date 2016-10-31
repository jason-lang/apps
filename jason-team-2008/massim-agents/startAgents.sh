###############################################################
#!/bin/sh                                                     #
###############################################################
# Multi-Agent Programming Contest 2008                        #
#                                                             # 
# Support package massim-demoAgents                           #
#   This script starts the 6 agents for 2 teams. They connect #
#   to a massim-Server running in the same host and with the  #
#   username and passwords specified. For more information    #
#   refer to the README file.                                 #
#                                                             #
# For the details on the contest, check the Contest website:  #
#   http://cig.in.tu-clausthal.de/agentcontest2008/           #
#                                                             #
# Organizers:                                                 #
#    J. Dix, M. Dastani, P. Novak, T.M. Behrens               #
###############################################################

server=localhost

echo "Launching Agents"
java -jar demoAgent.jar botagent1 1 $server &
java -jar demoAgent.jar botagent2 2 $server &
java -jar demoAgent.jar botagent3 3 $server &
java -jar demoAgent.jar botagent4 4 $server &
java -jar demoAgent.jar botagent5 5 $server &
java -jar demoAgent.jar botagent6 6 $server &
#java -jar demoAgent.jar participant1 1 $server &
#java -jar demoAgent.jar participant2 2 $server &
#java -jar demoAgent.jar participant3 3 $server &
#java -jar demoAgent.jar participant4 4 $server &
#java -jar demoAgent.jar participant5 5 $server &
#java -jar demoAgent.jar participant6 6 $server &
