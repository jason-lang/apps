/* Finish a round (now it is checked in the mod.newStep.asl) */
/*@simEndP1[atomic]
+simEnd[source(percept)]:
    true 
<-
    !finishSimulation. */
    
+!finishSimulation:
    .my_name(MyName) & friend(MyName, MyNameContest, _, _)
<-
    .send(coach, tell, simEnd).
 
@finishSimulation[atomic]  
+!finishSimulationLeader:
    .my_name(MyName) & friend(MyName, MyNameContest, _, _) & 
    .findall(artifact(NameArt, IdArt), artifact(NameArt, IdArt) & NameArt \== schDomainMars, ListArt) &
    artifact(schDomainMars, IdArtScheme)
<-
    .print("Contest finished!");
    !stopFocusArtifact(schDomainMars, IdArtScheme);
    !resetSystem;
    !initNewRound;
    !loadAgentNames;
    +myNameInContest(MyNameContest);
    
    for (.member(artifact(NameArt, IdArt), ListArt)) {
    	+artifact(NameArt, IdArt);
    };
    .send(coach, tell, finishedReset).
    
+!resetSystem:
    true
<-
    ia.resetGraph;
    .abolish(_[source(self)]);
    for (friend(Agent, _, _, _)) {
    	.abolish(_[source(Agent)]);
    };
    .drop_all_intentions;
    .drop_all_desires.
    
+bye <- .stopMAS.