
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
    !resetSystem;
    !stopFocusArtifact(schDomainMars, IdArtScheme);
    !initNewRound;
    !loadAgentNames;
    +myNameInContest(MyNameContest);
    
    for (.member(artifact(NameArt, IdArt), ListArt)) {
    	+artifact(NameArt, IdArt);
    };
    .send(coach, tell, finishedReset).
    
+!finishSimulationLeader <-
	.print("Something wrong to finish the contest!").
	
-!finishSimulationLeader[error(ErrorCode),error_msg(MsgError)] <-
	.print("Error occurred to finish the contest! ", ErrorCode, " -> ", MsgError).
    
+!resetSystem:
    true
<-
    ia.resetGraph;
    /*
    for (friend(Agent, _, _, _)) {
    	.abolish(_[source(Agent)]);
    }; */
    .abolish(_[source(self)]);
    
    //all beliefs changed by tell
	.abolish(acceptedAppointment); //all
	.abolish(canCome(_)); //all
	.abolish(islandIsFree); //saboteur
	.abolish(enemyAtIsland(_, _, _)); //saboteur
	.abolish(hit(_, _)); //repairer
    
    .drop_all_intentions;
    .drop_all_desires.
    
+bye <- .stopMAS.