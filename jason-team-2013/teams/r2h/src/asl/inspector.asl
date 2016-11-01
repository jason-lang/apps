{ include("mod.common.asl") }

//Inspecionar agentes distantes
/* É muito ruim dar inspect a distância, perde muito
is_inspect_goal(Entity) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, V, Team, _) & Team \== MyTeam & ia.edge(MyV,V,_) 
                  & not entityType(Entity, _) &
                  not (
                  	visibleEntity(EntityFriend, V, MyTeam, normal) & 
                  	friend(AgentName, EntityFriend, inspector, _) &
                  	EntityFriend \== MyName & 
                  	priorityEntity(AgentName, MyAgentName)
                  ). */

//There is no priority because one of them can fail
is_inspect_goal(V) :- not is_disabled & position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, V, Team, _) & Team \== MyTeam & ia.edge(MyV,V,_) 
                  	& not entityType(Entity, _, _, _, _).
                  
is_inspect_goal :- not is_disabled & position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, _) & Team \== MyTeam
				  & not entityType(Entity, _, _, _, _).

+!wait_and_select_goal <- !select_goal.
-!wait_and_select_goal[error(deadline_reached)] <- .print("Deadline reached"); !select_goal.

+!select_goal: is_energy_goal 
		<- !init_goal(recharge).
+!select_goal : is_wait_repair_goal(V) 
		<- .print("Waiting to be repaired. Recharging..."); 
    		!init_goal(recharge).
+!select_goal : not canCome & is_wait_repair_goal_nearby(V) 
		<- .print("Waiting to be repaired (nearby). Recharging..."); 
    		!init_goal(recharge).
+!select_goal : is_goto_repair_goal_nearby(V) 
		<- .print("Goto to be repaired (nearby)..."); 
    		!init_goal(goto(V)).
    		
+!select_goal: is_disabled & get_vertex_to_go_be_repaired_appointment(D, Path) 
		<- 
			.print("I have an appointment with some repairer. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
+!select_goal: is_disabled & get_vertex_to_go_be_repaired_appointment_self(D, Path) 
		<- 
			.print("I have an self appointment with some repairer. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
+!select_goal: is_disabled & get_vertex_to_go_repair(D, Path) 
		<- 
			.print("I'm forever alone. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).	
    		
+!select_goal: is_inspect_goal //TODO verificar quando tem sabotador? Tem apenas 4 sabotadores, é necessário se preocupar?
		<- !init_goal(inspect).
+!select_goal: is_inspect_goal(Op)
		<- !init_goal(goto(Op)).
+!select_goal: is_survey_goal & not is_leave_goal
		<- !init_goal(survey).
		
+!select_goal : going_to_outside_goal(V) <-
    .print("I'm inside a region. I can expand to ", V); 
    !init_goal(goto(V)).
		
+!select_goal : can_expand_to(V) <-
    .print("I can expand to ", V); 
    !init_goal(goto(V)).
    
+!select_goal: is_goal_keep_aim_vertex
		<- 
			.print("I'm at a pivot vertex. Recharging...");
			!init_goal(recharge).
		
+!select_goal: is_goal_aim_vertex(Op) 
		<- 
			.print("I have a pivot vertex to go. I'm going to ", Op);
			!init_goal(goto(Op)).
+!select_goal: is_goal_aim_vertex(D, Path) 
		<- 
			.print("I have a pivot vertex to go. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
		
+!select_goal                  
		<- !init_goal(random_walk).
		
+inspectedEntity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange):
    step(S) & not myTeam(Team) & artifact(inspectArtifact, IdInspectArtifact)
<-
    addEntity(Entity, Type, MaxHealth, Strength, VisRange)[artifact_id(IdInspectArtifact)];
    .print("The entity ", Entity, " was inspected Energy (", Energy, ",", MaxEnergy, ") Health (", Health, ",", MaxHealth, ") Strength ", Strength).
		
/*
 * These functions must be dependent of each kind of agent because they will
 * need to share some information with the other friends of the same kind
 */
@do0[atomic]
+!do(Act): 
    step(S) & stepDone(S)
<- 
    .print("ERROR! I already performed an action for this step! ", S).

@do1[atomic]
+!do(Act): 
    true
<- 
    !commitAction(Act).
    
+!initSpecific.
+!processAfterStep(S).
	
