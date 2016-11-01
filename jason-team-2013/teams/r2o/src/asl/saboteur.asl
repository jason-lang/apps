
{ include("mod.common.asl") }

/* BUY Stragegy
//All saboteurs
is_buy_goal(shield) :- not is_disabled & money(M) & M >= 8 &
						maxHealth(MaxHealth) & healthRequired(Required) & MaxHealth < Required.

is_buy_goal(sabotageDevice) :- not is_disabled & money(M) & M >= 8 &
								strength(Str) & strengthRequired(Required) & Str < Required.

//Only leader
is_buy_goal(sensor) :- .my_name(MyName) & play(MyName,saboteurLeader,"grMain") & 
						not is_disabled & money(M) & M > 2 &
						visRange(Vis) & Vis < 6.
						
is_buy_goal(sabotageDevice) :- .my_name(MyName) & play(MyName,saboteurLeader,"grMain") & 
						not is_disabled & money(M) & M > 2 &
						strength(Str) & Str < 6.
						
is_buy_goal(sensor) :- .my_name(MyName) & play(MyName,saboteurLeader,"grMain") & 
						not is_disabled & money(M) & M > 2 &
						visRange(Vis) & Vis < 10. */

//attack if there is an enemy at the same vertex
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Inspector", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Repairer", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam
                          & not nextStepSaboteur(_,Entity,S).
                          
//ranged version
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & ia.edge(MyV,V,_) & Team \== MyTeam & 
						  entityType(Entity, "Saboteur", _, _, _) &
                          not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & ia.edge(MyV,V,_) & Team \== MyTeam & 
						  entityType(Entity, "Repairer", _, _, _) &
                          not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & ia.edge(MyV,V,_) & Team \== MyTeam & 
						  entityType(Entity, "Explorer", _, _, _) &
                          not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & ia.edge(MyV,V,_) & Team \== MyTeam & 
						  entityType(Entity, "Inspector", _, _, _) &
                          not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & ia.edge(MyV,V,_) & Team \== MyTeam & 
                          not nextStepSaboteur(_,Entity,S).
                          

is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & ia.getDistance(MyV, V, Distance) & allowedDistanceAttack(Vis, Allowed) & Distance <= Allowed &
						  entityType(Entity, "Saboteur", _, _, _) &
                          not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & ia.getDistance(MyV, V, Distance) & allowedDistanceAttack(Vis, Allowed) & Distance <= Allowed &
						  entityType(Entity, "Repairer", _, _, _) &
                          not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & ia.getDistance(MyV, V, Distance) & allowedDistanceAttack(Vis, Allowed) & Distance <= Allowed &
						  entityType(Entity, "Explorer", _, _, _) &
                          not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & ia.getDistance(MyV, V, Distance) & allowedDistanceAttack(Vis, Allowed) & Distance <= Allowed &
						  entityType(Entity, "Inspector", _, _, _) &
                          not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & visRange(Vis) & Vis > 1 & position(MyV) & step(S) & myTeam(MyTeam) & 
						  visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & ia.getDistance(MyV, V, Distance) & allowedDistanceAttack(Vis, Allowed) & Distance <= Allowed &
                          not nextStepSaboteur(_,Entity,S).


/*
 * TEST IF THERE ARE ALREADY SABOTEUR FRIEND THERE
 */
/*
 * Test if there is some enemy at some adjacent vertex. It regards to:
 * - I have enough energy to go to the vertex and execute the action attack (MyE >= W + CostAttack), where W is the cost of the edge and CostAttack is the cost of the attack action
 * I may have more options, so I choose ramdomly
 */
there_is_enemy_nearby(Op) :- step(S) & not is_disabled & position(MyV) & myTeam(MyTeam) & maxWeight(INF) & energy(MyE) & costAttack(CostAttack) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                    W \== INF & 
                                    visibleEntity(Entity, V, Team, normal) & 
                                    Team \== MyTeam & 
                                    MyE >= W + CostAttack &
                                    not there_are_friends_saboteurs_at(V) &
                                    not nextStepSaboteur(_,Entity,S) & not nextStepSaboteur(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- step(S) & not is_disabled & position(MyV) & myTeam(MyTeam) & infinite(INF) & energy(MyE) & costAttack(CostAttack) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                        W \== INF & 
                                        visibleEntity(Entity, V, Team, normal) & 
                                        Team \== MyTeam & 
                                        MyE >= W + CostAttack &
                                        not there_are_friends_saboteurs_at(V) &
                                        not nextStepSaboteur(_,Entity,S) & not nextStepSaboteur(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * The only different is that I don't regard to my Energy and cost of the edge.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- step(S) & not is_disabled & position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                    W \== INF & 
                                    visibleEntity(Entity, V, Team, normal) & 
                                    Team \== MyTeam & 
                                    not there_are_friends_saboteurs_at(V) &
                                    not nextStepSaboteur(_,Entity,S) & not nextStepSaboteur(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- step(S) & not is_disabled & position(MyV) & myTeam(MyTeam) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                    W \== INF & 
                                    visibleEntity(Entity, V, Team, normal) & 
                                    Team \== MyTeam &
                                    not there_are_friends_saboteurs_at(V) &
                                    not nextStepSaboteur(_,Entity,S) & not nextStepSaboteur(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * This rule check if there is an adjacent vertex that is dominated by the enemy team, but it is possible that don't have any enemy there.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- step(S) & not is_disabled & position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                W \== INF & 
                                ia.vertex(V, Team) & 
                                Team \== none & 
                                Team \== MyTeam &
                                not there_are_friends_saboteurs_at(V) &
                                not nextStepSaboteur(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- step(S) & not is_disabled & position(MyV) & myTeam(MyTeam) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                    W \== INF & 
                                    ia.vertex(V, Team) & 
                                    Team \== none & 
                                    Team \== MyTeam &
                                    not there_are_friends_saboteurs_at(V) &
                                    not nextStepSaboteur(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
/* END SABOTEUR FRIEND */
 

/* Outside good area other agents */                                            
get_vertex_to_go_attack_search_others(D, Path) :- not is_disabled & position(MyV) & myTeam(MyTeam) & 
                                            .setof(V,
                                                visibleEntity(Entity, V, Team, normal) & 
                                                MyTeam \== Team &
                                                not there_are_friends_saboteurs_near(V)
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_attack_search_others(D, Path) :- not is_disabled & position(MyV) &
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                not there_are_friends_saboteurs_near(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.


is_attack_goal_always(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal_always(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal_always(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Inspector", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).

/* Protect island */       
get_vertex_to_go_attack_enemy_island(D, Path) :- not is_disabled & position(MyV) &
											chosenIslandToProtect(D, VerticesIsland,Agent) &
											not .member(MyV, VerticesIsland) &
                                            ia.shortestPath(MyV, D, Path, Lenght) &
                                            Lenght > 1.

is_protected_island_clean :- position(MyV) & myTeam(MyTeam) & chosenIslandToProtect(V, VerticesIsland, Agent) &
							.member(MyV, VerticesIsland) & not (
								.member(Vtest,VerticesIsland) &
								ia.vertex(Vtest, Team) & Team \== MyTeam
							).
							
is_attack_goal_island(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam &
							   chosenIslandToProtect(_, VerticesIsland,_) & .member(MyV,VerticesIsland)
                               & not nextStepSaboteur(_,Entity,S).
                               
there_is_enemy_nearby_island(Op) :- step(S) & not is_disabled & position(MyV) & myTeam(MyTeam) & chosenIslandToProtect(_, VerticesIsland,_) &
		                           .setof(V, ia.edge(MyV,V,_) & 
		                           			.member(V,VerticesIsland) &
		                                    visibleEntity(Entity, V, Team, normal) & 
		                                    Team \== MyTeam & 
		                                    not there_are_friends_saboteurs_at(V) &
		                                    not nextStepSaboteur(_,Entity,S) & not nextStepSaboteur(_,V,S), Options
		                           )
		                           & .length(Options, TotalOptions) & TotalOptions > 0 &
		                           .nth(math.random(TotalOptions), Options, Op).

there_is_enemy_nearby_island(Op) :- step(S) & not is_disabled & position(MyV) & myTeam(MyTeam) & chosenIslandToProtect(_, VerticesIsland,_) &
		                           .setof(V, ia.edge(MyV,V,_) & 
		                           		    .member(V,VerticesIsland) &
		                                    ia.vertex(V, Team) & 
		                                    Team \== none & 
		                                    Team \== MyTeam &
		                                    not there_are_friends_saboteurs_at(V) &
		                                    not nextStepSaboteur(_,V,S), Options
		                           )
		                           & .length(Options, TotalOptions) & TotalOptions > 0 &
		                           .nth(math.random(TotalOptions), Options, Op).
		                           
get_vertex_to_go_attack_search_island(D, Path) :- not is_disabled & position(MyV) & chosenIslandToProtect(_, VerticesIsland,_) &
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                .member(V,VerticesIsland) &
                                                not there_are_friends_saboteurs_near(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_most_valuable_island(V, VerticesIsland, MaxValue, Agent) :-
									        .setof(Value, 
									                enemyAtIsland(_, _, Value)
									               , Options) &
									        not .empty(Options) &
        									.max(Options,MaxValue) &
        									enemyAtIsland(V, VerticesIsland, MaxValue)[source(Agent)].

/* End protect island */

+!wait_and_select_goal:
    not numberWaits(_)
<-
    +numberWaits(0);
    !wait_and_select_goal.
    
+!wait_and_select_goal:
    (numberWaits(K) & K >= 15) | step(0)
<-
    .print("I can't wait anymore!");
    -+numberWaits(0);
    !select_goal.

+!wait_and_select_goal:
    .my_name(MyName) & number_agents_higher_priority_same_type(MyName, NumberRequired) &
    step(S) & .count(nextStepSaboteur(_, _, S), Number) &
	Number < NumberRequired &
	numberWaits(K)
<-  
    //.print("Waiting decision ", Number, "/", NumberRequired);
    .wait(50);
    -+numberWaits(K+1);
    !wait_and_select_goal.
+!wait_and_select_goal <- !select_goal.

+!select_goal: is_energy_goal 
		<- !init_goal(recharge).
+!select_goal : is_wait_repair_goal(V) 
		<- .print("Waiting to be repaired. Recharging..."); 
    		!init_goal(recharge).
+!select_goal : not canCome(ComeT) & is_wait_repair_goal_nearby(V, Repairer)
		<- .print("Waiting to be repaired (nearby). ", V , " ", Repairer, ". Recharging..."); 
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
    		
+!select_goal : is_good_map_conquered <-
    .print("Good map conquered! Stopped!"); 
    !init_goal(recharge).
+!select_goal: is_attack_goal_always(Entity) <-
	!init_goal(attack(Entity)).
/* Protect Island */
+!select_goal: is_attack_goal_island(Entity) <-
	.print("I'm at the island and I'm going to attack ", Entity); 
	!init_goal(attack(Entity)).
+!select_goal: is_attack_goal_island(Entity) <-
	.print("I'm at the island and I'm going to attack ", Entity); 
	!init_goal(attack(Entity)).
+!select_goal: get_vertex_to_go_attack_enemy_island(D, Path) & chosenIslandToProtect(VIsland, VerticesIsland, Agent) <-
	.print("I have an island to protect! Going to ", D, " using ", Path, " Island ", VIsland, " Vertices: ", VerticesIsland); 
	!init_goal(gotoPath(Path)).
+!select_goal: there_is_enemy_nearby_island(Op) <-
	.print("I'm at the island and I'm going to ", Op, " to find some enemy"); 
	!init_goal(goto(Op)).
+!select_goal: get_vertex_to_go_attack_search_island(D, Path) <-
	.print("I'm at the island and I'm going to ", D, " using ", Path, " to find some enemy"); 
	!init_goal(gotoPath(Path)).
/* End protect Island */

+!select_goal: is_attack_goal(Entity) <- !init_goal(attack(Entity)).
+!select_goal: there_is_enemy_nearby(Op) <- !init_goal(goto(Op)).

+!select_goal: is_survey_goal <- !init_goal(survey).
+!select_goal: is_buy_goal(What) <- !init_goal(buy(What)).

//+!select_goal: get_vertex_to_go_attack(D, Path) <- !init_goal(gotoPath(Path)).
+!select_goal: get_vertex_to_go_attack_search_others(D, Path) <- !init_goal(gotoPath(Path)).
		
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
			
//Hills
+!select_goal : can_expand_to_hill(V) <-
    .print("I'm at a hill and I can expand to ", V); 
    !init_goal(goto(V)).
    
+!select_goal : is_at_aim_position_hill <-
    .print("Stop! Stand still! I'm settled at the hill!"); 
    !init_goal(recharge).

+!select_goal: is_goal_hill_vertex(Op) 
		<- 
			.print("I have a hill vertex to go. I'm going to ", Op);
			!init_goal(goto(Op)).
+!select_goal: is_goal_hill_vertex(D, Path) 
		<- 
			.print("I have a hill vertex to go. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
			


+!select_goal                  
		<- !init_goal(random_walk).
		

/*
 * These functions must be dependent of each kind of agent because they will
 * need to share some information with the other friends of the same kind
 */
+!do(Act): 
    step(S) & stepDone(S)
<- 
    .print("ERROR! I already performed an action for this step! ", S).
    
+!do(Act): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents) &
    is_disabled
<- 
	.print("Sending action to ", S, " ", SetAgents);
	.send(SetAgents,tell,nextStepSaboteur(MyName, none, S));
    !commitAction(Act);
    !!clearNextStepSaboteur.

+!do(attack(Ag)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.print("Sending action to ", S, " ", SetAgents);
	.send(SetAgents,tell,nextStepSaboteur(MyName, Ag, S));
    !commitAction(attack(Ag));
    !!clearNextStepSaboteur.
    
+!do(goto(V)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.print("Sending action to ", S, " ", SetAgents);
	.send(SetAgents,tell,nextStepSaboteur(MyName, V, S));
    !commitAction(goto(V));
    !!clearNextStepSaboteur.

+!do(Act): 
    step(S) & position(V) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.print("Sending action to ", S, " ", SetAgents);
	.send(SetAgents,tell,nextStepSaboteur(MyName, V, S));
    !commitAction(Act);
    !!clearNextStepSaboteur.

+!clearNextStepSaboteur <-
	.abolish(nextStepSaboteur(_, _, _)).
    
+!initSpecific <-
    +strengthRequired(6);  
    +healthRequired(4);
    +costAttack(2);
    +allowedDistanceAttack(1, 0);
    +allowedDistanceAttack(2, 0);
    +allowedDistanceAttack(3, 1);
    +allowedDistanceAttack(4, 1);
    +allowedDistanceAttack(5, 2);
    +allowedDistanceAttack(6, 2);
    +allowedDistanceAttack(7, 3);
    +allowedDistanceAttack(8, 3);
    +allowedDistanceAttack(9, 4);
    +allowedDistanceAttack(10, 4).

+!processBeforeStep(S).
+!processAfterStep(S) <- 
	!updateEnemyIsland.

+!updateEnemyIsland:
	is_protected_island_clean & chosenIslandToProtect(V, VerticesIsland, Agent)
<-
	.print("Chosen island ", V, " ", VerticesIsland, " of agent ", Agent, " is clean");
	.abolish(chosenIslandToProtect(_, _, _));
	!!updateEnemyIsland.	
+!updateEnemyIsland:
	not chosenIslandToProtect(_,_,_) & get_most_valuable_island(V, VerticesIsland, Value, Agent)
<-
	.print("Chosen island ", V, " ", VerticesIsland, " of agent ", Agent, " with value ", Value, " to protect");
	+chosenIslandToProtect(V, VerticesIsland, Agent).
+!updateEnemyIsland.
