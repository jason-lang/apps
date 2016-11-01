{ include("mod.common.asl") }


//attack if there is an enemy at the same vertex
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).

is_attack_goal(Entity) :- not is_disabled & step(Step) & Step <= 150 & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Repairer", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Inspector", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer", _, _, _)
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam
                          & not nextStepSaboteur(_,Entity,S).
//is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur", MaxHealth, _, _) & strength(MyS) & MaxHealth > MyS.
//is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Repairer", _, _, _).
//is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer", _, _, _).
//is_attack_goal(Entity) :- not is_disabled & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Inspector", _, _, _).


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
 
/* Inside of good area I can look for enemies */
get_vertex_to_go_attack(D, Path) :- not is_disabled & position(MyV) & myTeam(MyTeam) & 
                                                allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            .setof(V,
                                                visibleEntity(Entity, V, Team, normal) & 
                                                not there_are_friends_saboteurs_near(V) &
                                                MyTeam \== Team &
                                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) & 
                                            Lenght > 2.

get_vertex_to_go_attack(D, Path) :- not is_disabled & position(MyV) & 
                                                allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                not there_are_friends_saboteurs_near(V) &
                                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

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




/*
 * Test if there is some enemy at some adjacent vertex. It regards to:
 * - I have enough energy to go to the vertex and execute the action attack (MyE >= W + CostAttack), where W is the cost of the edge and CostAttack is the cost of the attack action
 * I may have more options, so I choose ramdomly
 */
there_is_enemy_nearby_double(Op) :- not is_disabled & position(MyV) & myTeam(MyTeam) & maxWeight(INF) & energy(MyE) & costAttack(CostAttack) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & 
                           		W \== INF & 
                           		visibleEntity(Entity, V, Team, normal) & 
                           		Team \== MyTeam & 
                           		MyE >= W + CostAttack, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby_double(Op) :- not is_disabled & position(MyV) & myTeam(MyTeam) & infinite(INF) & energy(MyE) & costAttack(CostAttack) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & 
                           		W \== INF & 
                           		visibleEntity(Entity, V, Team, normal) & 
                           		Team \== MyTeam & 
                           		MyE >= W + CostAttack, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * The only different is that I don't regard to my Energy and cost of the edge.
 * I may have a set of options, so I choose randomly between all options
 */

there_is_enemy_nearby_double(Op) :- not is_disabled & position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & 
                           		W \== INF & 
                           		visibleEntity(Entity, V, Team, normal) & 
                           		Team \== MyTeam, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby_double(Op) :- not is_disabled & position(MyV) & myTeam(MyTeam) & infinite(INF) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & 
                           		W \== INF & 
                           		visibleEntity(Entity, V, Team, normal) & 
                           		Team \== MyTeam, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * This rule check if there is an adjacent vertex that is dominated by the enemy team, but it is possible that don't have any enemy there.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby_double(Op) :- not is_disabled & position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & 
                           		W \== INF & 
                           		ia.vertex(V, Team) & 
                           		Team \== none & 
                           		Team \== MyTeam, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby_double(Op) :- not is_disabled & position(MyV) & myTeam(MyTeam) & infinite(INF) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & 
                           		W \== INF & 
                           		ia.vertex(V, Team) & 
                           		Team \== none & 
                           		Team \== MyTeam, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).



+!wait_and_select_goal:
    not numberWaits(_)
<-
    +numberWaits(0);
    !wait_and_select_goal.
    
+!wait_and_select_goal:
    (numberWaits(K) & K >= 20) | step(0)
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
+!select_goal : is_wait_repair_goal_nearby(V) 
		<- .print("Waiting to be repaired (nearby). Recharging..."); 
    		!init_goal(recharge).
+!select_goal : is_goto_repair_goal_nearby(V) 
		<- .print("Goto to be repaired (nearby)..."); 
    		!init_goal(goto(V)).
    		
+!select_goal: is_disabled & get_vertex_to_go_be_repaired_appointment(D, Path) 
		<- 
			.print("I have an appointment with some repairer. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
+!select_goal: is_disabled & get_vertex_to_go_repair(D, Path) 
		<- 
			.print("I'm forever alone. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
    		
+!select_goal: is_attack_goal(Entity) <- !init_goal(attack(Entity)).
+!select_goal: there_is_enemy_nearby(Op) <- !init_goal(goto(Op)).
+!select_goal: get_vertex_to_go_attack(D, Path) <- !init_goal(gotoPath(Path)).
+!select_goal: get_vertex_to_go_attack_search_others(D, Path) <- !init_goal(gotoPath(Path)).

+!select_goal: is_survey_goal   
		<- !init_goal(survey).
		
+!select_goal: is_goal_pivot_vertex(Op) 
		<- 
			.print("I have a pivot vertex to go. I'm going to ", Op);
			!init_goal(goto(Op)).
+!select_goal: is_goal_pivot_vertex(D, Path) 
		<- 
			.print("I have a pivot vertex to go. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
			
+!select_goal: is_goal_keep_pivot_vertex
		<- 
			.print("I'm at a pivot vertex. Recharging...");
			!init_goal(recharge).
	
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
	.send(SetAgents,tell,nextStepSaboteur(MyName, none, S));
    !commitAction(Act);
    !!clearNextStepSaboteur.

+!do(attack(Ag)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.send(SetAgents,tell,nextStepSaboteur(MyName, Ag, S));
    !commitAction(attack(Ag));
    !!clearNextStepSaboteur.
    
+!do(goto(V)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.send(SetAgents,tell,nextStepSaboteur(MyName, V, S));
    !commitAction(goto(V));
    !!clearNextStepSaboteur.

+!do(Act): 
    step(S) & position(V) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.send(SetAgents,tell,nextStepSaboteur(MyName, V, S));
    !commitAction(Act);
    !!clearNextStepSaboteur.

+!clearNextStepSaboteur <-
	.abolish(nextStepSaboteur(_, _, _)).
    
+!initSpecific <-
    +strengthRequired(3);  
    +healthRequired(4);
    +costAttack(2).

+!processAfterStep(S).
    