{ include("mod.commonRules.asl") }
{ include("mod.commonWalkRules.asl") }

{ include("mod.loadAgents.asl") }
{ include("mod.finishRound.asl") }
{ include("mod.startRound.asl") }
{ include("mod.organization.asl") }
{ include("mod.environment.asl") }
{ include("mod.initialization.asl") }
{ include("mod.newStep.asl") }
{ include("mod.EISactions.asl") }
{ include("mod.walking.asl") }
{ include("mod.pivot.asl") }
{ include("mod.islands.asl") }
{ include("mod.aimVertex.asl") }
{ include("mod.repair.asl") }
{ include("mod.expanding.asl") }
{ include("mod.token.asl") }
{ include("mod.hills.asl") }
{ include("mod.swarm.asl") }
{ include("mod.swarm.expanding.asl") }


/*
 * Set my position as a visited vertex and tell my friends about it
 * Moreover, set my lastPosition to prevent I come back to there in the next step
 */  
+position(V):
    currentPosition(VOld) & step(S) &
    .my_name(MyName) & friend(MyName, _, _, Id)
<-
    !broadcastVisit(V, S);
    ia.setVertexVisited(V, S);
    ia.setAgentPosition(Id, V);
    -+lastPosition(VOld);
    -+currentPosition(V);
    !evaluateEnemiesPosition(V).
      
+position(V):
    not (lastPosition(_) | currentPosition(_)) & step(S) &
    .my_name(MyName) & friend(MyName, _, _, Id)
<-
    !broadcastVisit(V, S);
    ia.setVertexVisited(V, S);
    ia.setAgentPosition(Id, V);
    -+lastPosition(V);
    -+currentPosition(V);
    !evaluateEnemiesPosition(V).
    
+!broadcastVisit(V, S):
    not ia.visitedVertex(V, S) & .findall(Agent, friend(Agent, _, _, _), SetAgents)
<-
    .send(SetAgents, tell,visitedVertex(V, S)).
+!broadcastVisit(V, S): true <- true.

/* Percepts Entity */
//Get my team's name
+visibleEntity(Entity, V, Team, Status):
    myNameInContest(Entity) & not myTeam(_)
<-
    +myTeam(Team).
    
+visibleEntity(Entity, V, Team, Status)[source(percept)]:
    true
<-
    !addEnemyPosition(Entity, V, Team, Status).
    
+!evaluateEnemiesPosition(V):
	myTeam(MyTeam) & not (visibleEntity(Entity, V, Team, _) & MyTeam \== Team) &
	.my_name(MyName) & friend(MyName, _, _, Id)
<-
	ia.cleanPosition(Id, V).
+!evaluateEnemiesPosition(V).
    
+!addEnemyPosition(Entity, V, Team, normal):
    not myTeam(Team) & .my_name(MyName) & friend(MyName, _, _, Id)
<-
    ia.addEnemyPosition(Id, Entity, V).
    
+!addEnemyPosition(Entity, V, Team, disabled):
    not myTeam(Team) & .my_name(MyName) & friend(MyName, _, _, Id)
<-
    ia.remEnemyPosition(Id, Entity).
+!addEnemyPosition(_, _, _, _): true <- true.
    
+!remEnemyPosition(Entity, V, Team, normal):
    not myTeam(Team) & .my_name(MyName) & friend(MyName, _, _, Id)
<-
    ia.remEnemyPosition(Id, Entity).
+!remEnemyPosition(_, _, _, _): true <- true.

	
	
+health(0)[source(percept)]:
    .my_name(MyName) & position(Pos) & step(S) & not hit(_)
    & play(RepairerLeader,repairerLeader,"grMain") &
    not there_is_repairer_nearby(_) 
<-
	.abolish(selfAppointment(_, _));
    +hit(S);
    .send(RepairerLeader, tell, hit(MyName, Pos)).
    
+health(MyH)[source(percept)]:
    MyH > 0 & acceptedAppointment[source(AgentName)]
<-
    .send(AgentName, tell, iWasRepaired);
    .abolish(hit(_));
    .abolish(canCome(_));
    .abolish(acceptedAppointment);
    .abolish(selfAppointment(_, _)).
    
+health(MyH)[source(percept)]:
    MyH > 0 & selfAppointment(AgentName, _)
<-
    .abolish(hit(_));
    .abolish(canCome(_));
    .abolish(selfAppointment(_, _)).
    
+health(MyH)[source(percept)]:
    MyH > 0 
<-
    .abolish(hit(_));
    .abolish(canCome(_)).
    

@updateTotalSumVerticesP[atomic]
+!updateTotalSumVertices(Total):
    true
<-
    .abolish(sumVertices(_));
    +sumVertices(Total).