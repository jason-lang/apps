/* 
 * Jason Team for the
 * Multi-Agent Programming Contest 2009
 * (http://www.multiagentcontest.org)
 * 
 * By 
 *   Jomi F. Hubner     (UFSC, Brazil) 
 *   Rafael  H. Bordini (URFGS, Brazil)
 *   Gauthier Picard    (EMSE, France)
 *   Jaime S. Sichman            (USP, Brazil)
 *   Gustavo Pacianotto Gouveia  (USP, Brazil)
 *   Ricardo Hahn Pereira        (USP, Brazil)
 *   Michele Piunti              (Univ. Bologna, Italy)
 *
 * see proposal paper for the team in the doc directory.
 */


To run this team Jason 1.3 is required.

Steps:

1. run massim-server
     cd massim
     ./startSimulation2009.sh

   or some configuration for test
     ./startSimulation2009.sh conf/testmaps/<some conf file>.xml

   optionally start the GUI monitor
     ./startCowMonitor2009.sh

2. run dummies (written in Jason)
     ant -f dummies.xml
 
   or those written by the Contest developers  
     cd massim
     ./startAgents2009.sh

3. run Jason team 

     ant -f romanfarmers.xml (to run locally)

4. start the simulation
   go to shell running startServer.sh and press ENTER

5. you can get the agents location with the command
   
         tail -f world-status.txt 

   you can see the agent mind state in the mind-ag directory

6. to enable/disable the graphical view of some agent, add gui=yes
   or gui=no in the agent's option (.mas2j file)
