/* Finish a round */
@simEndP1[atomic]
+simEnd[source(percept)]:
    true 
<-
    !finishSimulation.
    
+!finishSimulation:
    .my_name(MyName) & friend(MyName, MyNameContest, _, _)
<-
    .print("Contest finished!"); 
    !resetSystem;
    !initNewRound;
    !loadAgentNames;
    +myNameInContest(MyNameContest);
    .send(coach, tell, simEnd).
    
+!resetSystem:
    true
<-
	!stopFocusArtifacts;
    .abolish(_);
    ia.resetGraph;
    .drop_all_intentions;
    .drop_all_desires.
	
+bye <- .stopMAS.