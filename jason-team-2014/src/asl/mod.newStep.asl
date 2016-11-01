+step(S):
    steps(S+1) & .my_name(inspector1)
<- 
    .print("Current step is ", S, " the last one! I'm inspector1 and I'm doing noAction on the last step!");
    !finishSimulation.
    
+step(S):
    steps(S+1) | (lastStep(LastS) & LastS > S)
<- 
    .print("Current step is ", S, " the last one!");
    .wait(100); //wait a bit because I can receive more information about the other agents
    !wait_and_select_goal;
    !finishSimulation.

+step(S):
    true
<- 
    .print("Current step is ", S);
    !processBeforeStep(S);
    !!testCleanIsland;
    !!testCleanPivot;
    .wait(100); //wait a bit because I can receive more information about the other agents
    !wait_and_select_goal;
    !sendToken(S);
    !evaluateHealth(S);
    -+lastStep(S);
    !processAfterStep(S);
    !evaluateCanCome(S);
    !!recoverySystem;
    !!addLineLog(S);
    !!synchronizeGraph.
	
@commitAction[atomic]
+!commitAction(Act): 
    step(S)
<- 
    -+stepDone(S);
    Act.
    
/* Which goal I'm going to follow */
+!init_goal(G): 
    money(M) & step(S) & position(V) & energy(E) & maxEnergy(Max) & lastActionResult(Result) & score(Score) & health(Health) & lastAction(LastAction) & lastStepScore(LastScore) & zonesScore(ZoneScore) & zoneScore(MyZoneScore)
<- 
    .print("I am at ",V," (",E,"/",Max,"), my health is ", Health, " the goal for step ",S," is ",G, " and I have ", M, " of money. My last result was ", Result, ". My last action was ", LastAction, ". The score is ", Score, " and my last score was ", LastScore, " with zones ", ZoneScore, " and my zone is ", MyZoneScore);
    !G.
    
+!init_goal(G): 
    step(S) & position(V) & energy(E) & maxEnergy(Max)
<- 
    .print("Something wrong... I'going try to don't lose the step. I'm at ",V," (",E,"/",Max,"). My action for step ",S," is ", G);
    !G.
      
+!init_goal(_)
<- 
    .print("No step yet... wait a bit");
    .wait(500);
    !wait_and_select_goal.
    
/* Log System */
+!addLineLog(S):
    lastActionResult(Result) & lastAction(LastAction) & .my_name(MyName) & friend(MyName, _, _, AgentId) & myTeam(MyTeam)
<-
    ia.addLastAction(MyTeam, AgentId, S, LastAction, Result).
+!addLineLog(S):
    .my_name(MyName) & friend(MyName, _, _, AgentId) & myTeam(MyTeam)
<-
    ia.addLastAction(MyTeam, AgentId, S, error, error).
+!addLineLog(_).
    
/* Graph synchronization */
+!synchronizeGraph:
    step(S) & lastSync(Last) & S - Last > 2
<-
    .print("Synchronizing...");
    -+lastSync(S);
    ia.synchronizeGraph.
+!synchronizeGraph:
    not lastSync(_)
<-
    +lastSync(0).
+!synchronizeGraph.

+!recoverySystem:
	not steps(_) | not edges(_) | not vertices(_)
<-
	.send(coach, askOne, steps(_));
	.send(coach, askOne, edges(_));
	.send(coach, askOne, vertices(_)).
+!recoverySystem.	
