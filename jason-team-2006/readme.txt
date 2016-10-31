This version of the JasonTeam runs only on Jason 0.8.2, it probably does not run in newer versions. However, the AgentSpeak code was improved and updated in a simulated environment of the Gold-Miners example that comes with new versions of Jason. 

A paper describing this implementation is available at
http://www.inf.furb.br/~jomi/pubs/2006/BordiniHubner-clima-contest06.pdf


--------------
Steps to run

1. Install the simulator
   http://cig.in.tu-clausthal.de/CLIMAContest
   
   also download an example team, but edit the
   startAgents script to run only the portuguese
   team.
   
2. start the simulator

3. start the other team
   (all four agent must login)
   
4. start the jason team with 
   	ant
   or start it with jason IDE
   (all four jason agent must login)

   You eventually should create the ant script again to
   set the correct paths of your installation. 
   To create this script:
	<jasondir>/bin/mas2j.sh jasonTeam.mas2j

5. Press Return in the simulator window to start the 
   simulation
