/* Organization Plans */
+!adoptRole(Role, Group) <-
	lookupArtifact(Group, IDGrGroup);
	focus(IDGrGroup);
	+artifact(Group, IDGrGroup);
	adoptRole(Role) [artifact_id(IDGrGroup)];
	.print("Adopted role ", Role, " in ", Group).
	
+!attendScheme(S) <-
	lookupArtifact(S, SchArtId);
	focus(SchArtId);
	+artifact(S,SchArtId);
	.print("Attending scheme ", S).
	
+!quit_mission(M,S) <-
	leaveMission(M) [artifact_name(S)].
	
+obligation(Ag,Norm,committed(Ag,Mission,Scheme),DeadLine): 
	.my_name(Ag) & not commitment(Ag,Mission,Scheme)
<- 
	.print("I am obliged to commit to ",Mission);
    commitMission(Mission)[artifact_name(Scheme)].
	
+obligation(Ag,Norm,achieved(Scheme,Goal,Ag),DeadLine): 
	.my_name(Ag)
<- 
	.print("I am obliged to achieve goal ", Goal);
	!Goal[artifact_name(Scheme)].
   	
/*
 * goal: probeAll
 */
+!probeAll[artifact_name(Scheme)]:
	ia.thereIsUnprobedVertex
<-
	.wait({+step(_)}, 1000); 
	!!probeAll[artifact_name(Scheme)].
-!probeAll[artifact_name(Scheme)]
<-
	!!probeAll[artifact_name(Scheme)].
+!probeAll[artifact_name(Scheme)] <-
	goalAchieved(probeAll)[artifact_name(Scheme)];
	.print("Probed all vertices").

/*
 * goal: defineInitialHills
 */
+!defineInitialHills[artifact_name(Scheme)]:
 	hill(_)
<-
	goalAchieved(defineInitialHills)[artifact_name(Scheme)];
	.print("Defined initial hills").
+!defineInitialHills[artifact_name(Scheme)]
<-
	.wait({+hill(_)}, 1000); 
	!!defineInitialHills[artifact_name(Scheme)].
-!defineInitialHills[artifact_name(Scheme)]
<-
	!!defineInitialHills[artifact_name(Scheme)].

/*
 * goal: discoverAllSaboteurs
 */
+!discoverAllSaboteurs[artifact_name(Scheme)]:
	.count(friend(_, _, saboteur, _), NSaboteurs) & .count(entityType(_, "Saboteur", _, _, _), NSaboteurs)
 <- 
 	goalAchieved(discoverAllSaboteurs)[artifact_name(Scheme)];
 	.print("Discovered all saboteurs").
+!discoverAllSaboteurs[artifact_name(Scheme)]
<-
	.wait({+entityType(_, "Saboteur", _, _, _)}, 10000); 
	!!discoverAllSaboteurs[artifact_name(Scheme)].
-!discoverAllSaboteurs[artifact_name(Scheme)]
<-
	!!discoverAllSaboteurs[artifact_name(Scheme)].
	

/*
 * goal: defineInitialPivotsInsideHill
 */
+!defineInitialPivotsInsideHill[artifact_name(Scheme)]:
 	pivots(List) & not .empty(List)
<-
	goalAchieved(defineInitialPivotsInsideHill)[artifact_name(Scheme)];
	.print("Defined initial pivots").
+!defineInitialPivotsInsideHill[artifact_name(Scheme)]
<-
	.wait({+pivots(_)}, 1000); 
	!!defineInitialPivotsInsideHill[artifact_name(Scheme)].
-!defineInitialPivotsInsideHill[artifact_name(Scheme)]
<-
	!!defineInitialPivotsInsideHill[artifact_name(Scheme)].

	
/*
 * goal: defineInitialIslands
 */
+!defineInitialIslands[artifact_name(Scheme)]:
 	islands(List) & not .empty(List)
<-
	goalAchieved(defineInitialIslands)[artifact_name(Scheme)];
	.print("Defined initial islands").
+!defineInitialIslands[artifact_name(Scheme)]
<-
	.wait({+islands(_)}, 1000); 
	!!defineInitialIslands[artifact_name(Scheme)].
-!defineInitialIslands[artifact_name(Scheme)]
<-
	!!defineInitialIslands[artifact_name(Scheme)].
	
	
/*
 * goal: defineInitialPivots
 */
+!defineInitialPivots[artifact_name(Scheme)]:
 	pivots(ListPivots) & islands(ListIslands) & not hill(_) &
 	not .empty(ListPivots) & not .empty(ListIslands)
<-
	goalAchieved(defineInitialPivots)[artifact_name(Scheme)];
	.print("Defined initial pivots").
+!defineInitialPivots[artifact_name(Scheme)]
<-
	.wait({+islands(_)}, 1000); 
	!!defineInitialPivots[artifact_name(Scheme)].
-!defineInitialPivots[artifact_name(Scheme)]
<-
	!!defineInitialPivots[artifact_name(Scheme)].