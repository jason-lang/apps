{ include("mod.loadAgents.asl") }

/*
 * Maintenance goals: posicionar sobre vertices pivot (sentinelas), manter-se dentro de uma area boa sem sair da mesma
 */

!start.

+!start <- 
    .my_name(Me);
	
	!!loadAgentNames;
	
	makeArtifact(grMain,"ora4mas.nopl.GroupBoard",["src/org/org.xml", team, false, true ],IDGrMain);
	setOwner(Me);
	focus(IDGrMain);
	+artifact(grMain, IDGrMain);
	
	makeArtifact(grAlpha,"ora4mas.nopl.GroupBoard",["src/org/org.xml", subTeam, false, true ],IDGrAlpha);
	setOwner(Me);
	focus(IDGrAlpha);
	+artifact(grAlpha, IDGrAlpha);
	
	makeArtifact(grBeta,"ora4mas.nopl.GroupBoard",["src/org/org.xml", subTeam, false, true ],IDGrBeta);
	setOwner(Me);
	focus(IDGrBeta);
	+artifact(grBeta, IDGrBeta);
	
	adoptRole(leader)[artifact_id(IDGrMain)];
	
	!callFriendsToJoinGroup;
	
	setParentGroup(grMain)[artifact_id(IDGrAlpha)];
	setParentGroup(grMain)[artifact_id(IDGrBeta)];
	
	!loadEnvironmentArtifacts.

/* If all agents are joined to the group, I can start the scheme */
+formationStatus(ok)[artifact_name(_,"grMain")] <-
	!setupScheme.
	
+!setupScheme <-
	!run_scheme(schDomainMars);
	!callFriendsToAttendScheme.
	
+!run_scheme(S): artifact(grMain,IDGrMain) & artifact(grAlpha,IDGrAlpha) & artifact(grBeta,IDGrBeta) <- 
    makeArtifact(S,"ora4mas.nopl.SchemeBoard",["src/org/org.xml", domainMars, false, true ],SchArtId);
	focus(SchArtId);
	+artifact(S,SchArtId);
	
	addScheme(S)[artifact_id(IDGrMain)];
	addScheme(S)[artifact_id(IDGrAlpha)];
	addScheme(S)[artifact_id(IDGrBeta)]; 
	
	.print("The scheme is on."). 
	
-!run_scheme(S)[error(I),error_msg(M)] <- .print("Failed to create scheme ",S," -- ",I,": ",M).
	
/* Call agents to join the group */
+!callFriendsToJoinGroup <-
	//Alpha
	.send([explorer1, explorer2, explorer6], achieve, adoptRole(explorer, grAlpha));
	.send([sentinel1, sentinel2, sentinel6], achieve, adoptRole(sentinel, grAlpha));
	.send([inspector1, inspector2, inspector6], achieve, adoptRole(inspector, grAlpha));
	.send([repairer1, repairer2, repairer6], achieve, adoptRole(repairer, grAlpha));
	.send([saboteur1, saboteur4], achieve, adoptRole(saboteur, grAlpha));
	
	//Main
	.send(explorer6, achieve, adoptRole(explorerLeader, grMain));
	.send(sentinel6, achieve, adoptRole(sentinelLeader, grMain));
	.send(inspector6, achieve, adoptRole(inspectorLeader, grMain));
	.send(repairer6, achieve, adoptRole(repairerLeader, grMain));
	.send(saboteur4, achieve, adoptRole(saboteurLeader, grMain));
	
	//Beta
	.send([explorer3, explorer4, explorer5], achieve, adoptRole(explorer, grBeta));	
	.send([sentinel3, sentinel4, sentinel5], achieve, adoptRole(sentinel, grBeta));
	.send([inspector3, inspector4, inspector5], achieve, adoptRole(inspector, grBeta));
	.send([repairer3, repairer4, repairer5], achieve, adoptRole(repairer, grBeta));
	.send([saboteur2, saboteur3], achieve, adoptRole(saboteur, grBeta));
	
	.send([
		   explorer1, explorer2, explorer3, explorer4, explorer5,
		   sentinel1, sentinel2, sentinel3, sentinel4, sentinel5,
		   inspector1, inspector2, inspector3, inspector4, inspector5,
		   repairer1, repairer2, repairer3, repairer4, repairer5,
		   saboteur1, saboteur2, saboteur3
	      ], 
		achieve, focusArtifact(grMain)
	).
	
	
/* Call agents to attend the scheme */
+!callFriendsToAttendScheme <-
	.send([
		   explorer1, explorer2, explorer3, explorer4, explorer5, explorer6,
		   sentinel1, sentinel2, sentinel3, sentinel4, sentinel5, sentinel6,
		   inspector1, inspector2, inspector3, inspector4, inspector5, inspector6,
		   repairer1, repairer2, repairer3, repairer4, repairer5, repairer6,
		   saboteur1, saboteur2, saboteur3, saboteur4
	      ], 
		achieve, attendScheme(schDomainMars)
	).
	
/* The round finished for all agentes */
+simEnd: 
	.count(friend(_, _, _, _), NAgents) & .count(simEnd[source(_)], NAgents)
<-
    .abolish(simEnd);
    .print("All agents finished!");
    !resetEnvironment;
    !resetAllAgents.
	
+simEnd[source(Ag)]: 
	.count(simEnd[source(_)],NEnds)
<-
    .print("Received simEnd from ", Ag, " ", NEnds).
    
+!resetAllAgents:
	true
<-
	.broadcast(achieve, focusArtifact(grMain));
	
	.send([
			explorer1, explorer2, explorer6,
	 		sentinel1, sentinel2, sentinel6,
	 		inspector1, inspector2, inspector6,
	 		repairer1, repairer2, repairer6,
	 		saboteur1, saboteur4
	 	], achieve, focusArtifact(grAlpha));
	 	
	.send([
			explorer3, explorer4, explorer5,
	 		sentinel3, sentinel4, sentinel5,
	 		inspector3, inspector4, inspector5,
	 		repairer3, repairer4, repairer5,
	 		saboteur2, saboteur3
	 	], achieve, focusArtifact(grBeta));
	
	//TODO talvez esse nao precisa
	.broadcast(achieve, focusArtifact(schDomainMars));
	
	.broadcast(achieve, focusArtifact(inspectArtifact)).
+!focusArtifact.


/*
 * Load environment artifacts
 */
+!loadEnvironmentArtifacts <- 
	makeArtifact(inspectArtifact,"artifacts.InspectArtifact",[],IdInspectArtifact);
	+artifact(inspectArtifact, IdInspectArtifact);
	focus(IdInspectArtifact);
	.broadcast(achieve, focusArtifact(inspectArtifact)).
	
+!resetEnvironment:
 	artifact(inspectArtifact, IdInspectArtifact)
 <-
	reset[artifact_id(IdInspectArtifact)].
	
	
	
+count(X)
   <- .print("Count is ",X).
   
-count(X)
   <- .print("NON Count is ",X).