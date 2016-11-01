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
 
/* Fica restos na base de crenças porque outros agentes continuam executando, por isso
 * o coach deve chamar
 */
@finishSimulation[atomic]  
+!finishSimulationLeader:
    .my_name(MyName) & friend(MyName, MyNameContest, _, _)
<-
    .print("Contest finished!"); 
    !resetSystem;
    !initNewRound;
    !loadAgentNames;
    +myNameInContest(MyNameContest).
    //.send(coach, tell, simEnd).
    
    
/*
 * TODO
 * Testar bem essa parte de migrar de um round para outro
 */
+!resetSystem:
    true
<-
	//!stopFocusArtifacts;
    //ia.cleanBeliefBase;
    //.abolish(_);
    .abolish(_[source(self)]);
    for (friend(Agent, _, _, _)) {
    	.abolish(_[source(Agent)]);
    };
    ia.resetGraph;
    .drop_all_intentions;
    .drop_all_desires.
    
+bye <- .stopMAS.