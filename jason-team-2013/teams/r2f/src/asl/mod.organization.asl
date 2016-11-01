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
	.my_name(Ag)
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
 * goal: surveyAll
 */
+!surveyAll[artifact_name(Scheme)] <- .print("Going to achieve surveyAll").

/*
 * goal: discoverAllSaboteurs
 */
+!discoverAllSaboteurs[artifact_name(Scheme)] <- .print("Going to achieve discoverAllSaboteurs").

/*
 * goal: occupyPivotVertices
 */
+!occupyPivotVertices[artifact_name(Scheme)] <- .print("Going to achieve occupyPivotVertices").


+goalState(_,probeAll,_,_,satisfied)
<-
	.print("Meta probeAll satisfeita").