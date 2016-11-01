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

//Get my team's name
+visibleEntity(Entity, V, Team, Status):
    myNameInContest(Entity) & not myTeam(_)
<-
    +myTeam(Team).
     
/*
 * Set my position as a visited vertex and tell my friends about it
 * Moreover, set my lastPosition to prevent I come back to there in the next step
 */  
+position(V):
    currentPosition(VOld) & step(S)
<-
    !broadcastVisit(V, S);
    ia.setVertexVisited(V, S);
    -+lastPosition(VOld);
    -+currentPosition(V).
      
+position(V):
    not (lastPosition(_) | currentPosition(_)) & step(S)
<-
    !broadcastVisit(V, S);
    ia.setVertexVisited(V, S);
    -+lastPosition(V);
    -+currentPosition(V).
    
+!broadcastVisit(V, S):
    not ia.visitedVertex(V, S) & .findall(Agent, friend(Agent, _, _, _), SetAgents)
<-
    .send(SetAgents, tell,visitedVertex(V, S)).
+!broadcastVisit(V, S): true <- true.