//agent saboteur
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_notRepairer.asl") }

/*
 * the buy strategy is only used by saboteur4, that has a different behavior than the other saboteurs
 * its aim is to do the enemy to buy a lot of things, since the buy strategy doesn't make sense with 4 saboteurs.
 * but, if the current opponent doesn't buy anything, so the agent also won't buy things because we will have problems if we buy and the enemy no.
 */
is_buy_goal    :- strategy(1) & not limitBuy & (is_buy_attack_goal | is_buy_shield_goal) & money(MyM) & MyM > 2.

/*
 * these two first rules try to do the opponent to buy things.
 * we have to buy the first time, because the opponent may wait we buy first!
 * the first thing is to get 6 of strength, so I can beat some repairer, and it is good in the first step. Also is important to beat explorers in 2 steps
 * it will do the opponent buy 7 of strength 
 */ 
is_buy_attack_goal    :- 
    strength(MyS) &
    (MyS < 6) & .my_name(saboteur4).

/*
 * my initial health is 4, so I can survive if I was attacked
 * it will do the opponent buy 1 strength
 */
is_buy_shield_goal    :- 
        myMaxHealth(MyH) & 
        (MyH < 4) & .my_name(saboteur4).

/* if the enemy are buying things or the current step > 150, so I try buy more health. Maybe the opponent are following our buys and spending a lot of money to protect their saboteurs with 7 of health and 4 of strength. So, right now I do the opponent buy more!
 * this rule only makes sense after step 150, because we already bought things enough to lead the opponent to spend all their current money (two first rules).
 * after it, we assume that is almost impossible the opponent get more than 64 of money until step 300
 * so, if all saboteurs are buying we will have after this rule:
 * health = 7 (4 buys)
 * strength = 7 (4 buys)
 * total = 8 buys 
 * total * saboteurs = 8 * 4 = 32 
 * total * 2 (cost of a buy) = 32 * 2 = 64 
 * */
is_buy_shield_goal    :- 
        myMaxHealth(MyH) &
            (
            strengthRequired(Sr) & Sr > 3 
            | 
            healthRequired(Hr) & Hr > 4
            |
            step(CurrentS) & CurrentS > 150 
            ) & 
        (MyH < 7) & .my_name(saboteur4).

/* with total of 8 buys of our team (5 health and 3 strength) we can turn 0 achievements to the opponent in 750 steps
 * after step 250 we buy one more health, so the opponent will buy 1 more strength for each saboteur
 * we will have 64 + (4 * 2) = 72
 * we guess 72 is very close to the max possible money for 750 steps. 
 */
is_buy_shield_goal    :- 
        myMaxHealth(MyH) & 
        step(CurrentS) & CurrentS > 250 & 
            (
            strengthRequired(Sr) & Sr > 3 
            | 
            healthRequired(Hr) & Hr > 4
            ) &
        (MyH < 8) & .my_name(saboteur4).

/* if there are more than 750 steps, so I need only 1 buy more, because the opponent can get at most 80 of money.
 * */
is_buy_shield_goal    :- 
        myMaxHealth(MyH) & 
        steps(TotalS) & TotalS >= 800 & step(CurrentS) & CurrentS > 600 &
            (
            strengthRequired(Sr) & Sr > 3 
            | 
            healthRequired(Hr) & Hr > 4
            ) &
        (MyH < 9) & .my_name(saboteur4).
                  
//attack if there is an enemy at the same vertex
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur")
                          & not nextStepSaboteur(_,Entity,S).

is_attack_goal(Entity) :- step(Step) & Step <= 200 & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer")
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Repairer")
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Inspector")
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer")
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam
                          & not nextStepSaboteur(_,Entity,S).
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Saboteur") & strength(MyS) & entityHealth(Entity,MaxHealth) & MaxHealth > MyS.
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Repairer").
is_attack_goal(Entity) :- position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & entityType(Entity, "Explorer").
                          
there_is_more_saboteurs(SaboteurNameFriend) :- position(MyV) & step(S) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyNameJason) &
                            visibleEntity(Entity, MyV, MyTeam, normal) & 
                            Entity \== MyName &
                            friend(SaboteurNameFriend, Entity, saboteur) & 
                            visibleEntity(EntityTwo, MyV, Team, normal) &
                            Team \== MyTeam &
                            priorityEntity(SaboteurNameFriend, MyNameJason) &
                            not nextStepSaboteur(SaboteurNameFriend, _, S).

//Test if there is other saboteurs at the same vertex and I have the highest priority
i_have_more_priority :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyAgentName) &
                  not (visibleEntity(Entity, MyV, MyTeam, normal) & friend(AgentName, Entity, saboteur) & Entity \== MyName & priorityEntity(AgentName, MyAgentName)).


/*
 * TEST IF THERE ARE ALREADY SABOTEUR FRIEND THERE
 */
/*
 * Test if there is some enemy at some adjacent vertex. It regards to:
 * - I have enough energy to go to the vertex and execute the action attack (MyE >= W + CostAttack), where W is the cost of the edge and CostAttack is the cost of the attack action
 * I may have more options, so I choose ramdomly
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) & energy(MyE) & costAttack(CostAttack) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                    W \== INF & 
                                    visibleEntity(Entity, V, Team, normal) & 
                                    Team \== MyTeam & 
                                    MyE >= W + CostAttack &
                                    not there_are_friends_saboteurs_at(V), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & energy(MyE) & costAttack(CostAttack) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                        W \== INF & 
                                        visibleEntity(Entity, V, Team, normal) & 
                                        Team \== MyTeam & 
                                        MyE >= W + CostAttack &
                                        not there_are_friends_saboteurs_at(V), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * The only different is that I don't regard to my Energy and cost of the edge.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                    W \== INF & 
                                    visibleEntity(Entity, V, Team, normal) & 
                                    Team \== MyTeam & 
                                    not there_are_friends_saboteurs_at(V), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                    W \== INF & 
                                    visibleEntity(Entity, V, Team, normal) & 
                                    Team \== MyTeam &
                                    not there_are_friends_saboteurs_at(V), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * This rule check if there is an adjacent vertex that is dominated by the enemy team, but it is possible that don't have any enemy there.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                W \== INF & 
                                ia.vertex(V, Team) & 
                                Team \== none & 
                                Team \== MyTeam &
                                not there_are_friends_saboteurs_at(V), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                                    W \== INF & 
                                    ia.vertex(V, Team) & 
                                    Team \== none & 
                                    Team \== MyTeam &
                                    not there_are_friends_saboteurs_at(V), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
/* END SABOTEUR FRIEND */



/*
 * Test if there is some enemy at some adjacent vertex. It regards to:
 * - I have enough energy to go to the vertex and execute the action attack (MyE >= W + CostAttack), where W is the cost of the edge and CostAttack is the cost of the attack action
 * I may have more options, so I choose ramdomly
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) & energy(MyE) & costAttack(CostAttack) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & MyE >= W + CostAttack, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & energy(MyE) & costAttack(CostAttack) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam & MyE >= W + CostAttack, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * The only different is that I don't regard to my Energy and cost of the edge.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, Team, normal) & Team \== MyTeam, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * This rule check if there is an adjacent vertex that is dominated by the enemy team, but it is possible that don't have any enemy there.
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.vertex(V, Team) & Team \== none & Team \== MyTeam, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.vertex(V, Team) & Team \== none & Team \== MyTeam, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
noMoreVertexToProbe :- true.

/* Inside of good area */
get_vertex_to_go_attack(D, Path) :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
                                                allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            .setof(V,
                                                visibleEntity(Entity, V, Team, normal) & 
                                                MyTeam \== Team &
                                                (not entityType(Entity, _) | entityType(Entity, "Saboteur") | is_suspect(Entity)) &
                                                not there_are_friends_saboteurs_near(V) &
                                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_attack(D, Path) :- position(MyV) & 
                                                allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                (not entityType(Entity, _) | entityType(Entity, "Saboteur") | is_suspect(Entity)) &
                                                not there_are_friends_saboteurs_near(V) &
                                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) & 
                                            Lenght > 2.

get_vertex_to_go_attack(D, Path) :- position(MyV) & myTeam(MyTeam) & 
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

get_vertex_to_go_attack(D, Path) :- position(MyV) & 
                                                allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                not there_are_friends_saboteurs_near(V) &
                                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

/* Outside of good area - saboteur4 */
get_vertex_to_go_attack_search(D, Path) :- position(MyV) & myTeam(MyTeam) & step(Step) & Step <= 200 & 
                                            .setof(V,
                                                visibleEntity(Entity, V, Team, normal) & 
                                                MyTeam \== Team &
                                                entityType(Entity, "Explorer") & 
                                                not there_are_friends_saboteurs_near(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_attack_search(D, Path) :- position(MyV) & step(Step) & Step <= 200 & 
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                entityType(Entity, "Explorer") &
                                                not there_are_friends_saboteurs_near(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.
                                            
get_vertex_to_go_attack_search(D, Path) :- position(MyV) & myTeam(MyTeam) & 
                                            .setof(V,
                                                visibleEntity(Entity, V, Team, normal) & 
                                                MyTeam \== Team &
                                                not (entityType(Entity, "Saboteur") | is_suspect(Entity) | entityType(Entity, "Repairer")) &
                                                not there_are_friends_saboteurs_near(V)
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_attack_search(D, Path) :- position(MyV) &
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                not (entityType(Entity, "Saboteur") | is_suspect(Entity) | entityType(Entity, "Repairer")) &
                                                not there_are_friends_saboteurs_near(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.
                                            


/* Outside good area other agents */
get_vertex_to_go_attack_search_others(D, Path) :- position(MyV) & myTeam(MyTeam) & step(Step) & Step <= 200 & 
                                            .setof(V,
                                                visibleEntity(Entity, V, Team, normal) & 
                                                MyTeam \== Team &
                                                (not entityType(Entity, _) | entityType(Entity, "Saboteur") | is_suspect(Entity)) &
                                                not there_are_friends_saboteurs_near(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_attack_search_others(D, Path) :- position(MyV) & step(Step) & Step <= 200 & 
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                (not entityType(Entity, _) | entityType(Entity, "Saboteur") | is_suspect(Entity)) &
                                                not there_are_friends_saboteurs_near(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.
                                            
get_vertex_to_go_attack_search_others(D, Path) :- position(MyV) & myTeam(MyTeam) & 
                                            .setof(V,
                                                visibleEntity(Entity, V, Team, normal) & 
                                                MyTeam \== Team &
                                                not there_are_friends_saboteurs_near(V)
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_attack_search_others(D, Path) :- position(MyV) &
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                not there_are_friends_saboteurs_near(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.
        
/*
 * Getting around / search enemy
 */ 
get_vertex_getting_around(D, Path) :- position(MyV) & get_all_best_vertex(ListBest) & myTeam(MyTeam) &
                                            .setof(V,
                                                .member(V, ListBest) & 
                                                not visitedBestVertex(V) &
                                                not visibleEntity(_, V, MyTeam, _) &
                                                not there_are_friends_near(V) &
                                                not (friend(AgentName, _, _) & generalPriority(AgentName, Id) & ia.getAgentPosition(Id, V)) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 1.
                                            
/* The sequence of the priority plans */
+!select_goal:
    there_is_more_saboteurs(SaboteurNameFriend) & not numberWaits(_)
<-
    +numberWaits(0);
    !select_goal.
    
+!select_goal:
    (there_is_more_saboteurs(SaboteurNameFriend) & numberWaits(K) & K >= 6) | (step(0) & not nextStepSaboteurAll(10))
<-
    .print("I can't wait anymore!");
    -+numberWaits(0);
    -+nextStepSaboteurAll(10);
    !select_goal.

+!select_goal:
    there_is_more_saboteurs(SaboteurNameFriend) & numberWaits(K)
<-  
    .print("Waiting decision ", SaboteurNameFriend);
    .wait(150);
    -+numberWaits(K+1);
    !select_goal.



+!select_goal : is_heartbeat_goal
    <-
    .print("I'm in the same place yet!!!!!!");
    .abolish(stepsSamePosition(_, _));
    !select_goal.

+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_wait_repair_goal(V) <-
    .print("Waiting to be repaired."); 
    !init_goal(waitRepair(V)).
+!select_goal : is_route_repaired_goal <- !reviewMyPositionRepaired; !init_goal(repair_walk). //I'm going to be repaired by some agent

+!select_goal : is_buy_goal & 
                canBuy & 
                not is_disabled & 
                position(Pos) & 
                not there_is_enemy_at(Pos) <- !init_goal(buy).
+!select_goal : 
                is_buy_goal & 
                not canBuy & 
                not is_disabled & 
                not askedBuy &
                position(Pos) &   
                not there_is_enemy_at(Pos) <- !tryAskBuy.
+!select_goal : waitABit <- !init_goal(recharge).

+!select_goal : is_disabled <- !init_goal(walk_repair_forever_alone).

+!select_goal : is_attack_goal(Entity) & not is_disabled <- !init_goal(attack(Entity)).
+!select_goal : not is_almost_full_map & there_is_enemy_nearby(Op) & not is_disabled <- !init_goal(followEnemy(Op)).
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).

+!select_goal : not .my_name(saboteur4) & pathTogoSwarm(_, _) & not is_at_swarm_position & pathTogoSwarm(_, []) <- !cancelSwarmTravel; !select_goal.
+!select_goal : not .my_name(saboteur4) & not is_almost_full_map & pathTogoSwarm(_, _) & not is_at_swarm_position <- !init_goal(walkSwarm).

+!select_goal : not is_disabled & is_good_map_conquered <-
    .print("Good map conquered!"); 
    !init_goal(recharge).
    
+!select_goal : not is_disabled & not .my_name(saboteur4) & not there_is_enemy_inside_my_good_area(V) & is_at_swarm_position_test & 
                can_expand_to(V) <-
    .print("Stop! Stand still! I can expand to ", V); 
    !init_goal(goto(V)).
    
+!select_goal : not is_disabled & not .my_name(saboteur4) & not there_is_enemy_inside_my_good_area(V) & is_at_swarm_position_test <-
    .print("Stop! Stand still!"); 
    !init_goal(recharge).

+!select_goal : not .my_name(saboteur4) & there_is_enemy_inside_my_good_area(V) & get_vertex_to_go_attack(D, Path) <-
    .print("Going to attack some enemy at(1) ", D); 
    !init_goal(gotoPathAttack(Path)).
+!select_goal : not .my_name(saboteur4) & not is_at_swarm_position & get_vertex_to_go_attack_search_others(D, Path) <-
    .print("Going to attack some enemy at(2) ", D); 
    !init_goal(gotoPathAttack(Path)).

+!select_goal : step(S) & .my_name(saboteur4) & get_vertex_to_go_attack_search(D, Path) <-
    .print("Going attack to ", D, " with path ", Path);
    .abolish(stepCanGettingAround(_));
    +stepCanGettingAround(S+30);
    !init_goal(gotoPathAttack(Path)).
    
/* TODO Not tested enough
+!select_goal : .my_name(saboteur4) & 
                (not stepCanGettingAround(_) | step(S) & stepCanGettingAround(StepGetting) & S > StepGetting) & get_vertex_getting_around(D, Path) <-
    .print("Getting around to ", D, " with path ", Path);
    !init_goal(gotoPathAttack(Path)). */

+!select_goal: .my_name(saboteur4) &
                (not stepCanGettingAround(_) | step(S) & stepCanGettingAround(StepGetting) & S > StepGetting) & 
                noMoreVertexToProbe & not is_at_swarm_position & get_vertex_to_go_swarm(D, Path) <-
    !clearGettingAround;
    !init_goal(gotoPathFastSwarm(Path)).
+!select_goal: noMoreVertexToProbe & not is_at_swarm_position & get_vertex_to_go_swarm(D, Path) <- !init_goal(gotoPathFastSwarm(Path)).

+!select_goal: .my_name(saboteur4) <-
    !clearGettingAround; 
    !init_goal(random_walk).
+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
    true
<-
    +strengthRequired(3);  
    +healthRequired(4);
    +costAttack(2);
    
    +priorityEntity(saboteur1, saboteur2);
    +priorityEntity(saboteur1, saboteur3);
    +priorityEntity(saboteur1, saboteur4);
    
    +priorityEntity(saboteur2, saboteur3);
    +priorityEntity(saboteur2, saboteur4);
    
    +priorityEntity(saboteur3, saboteur4);
    .print("Initialized!").
    
+!buy:
    is_buy_shield_goal & money(M) & myMaxHealth(MyH) & step(S)
<- 
    .abolish(canBuy);
    .abolish(lastBuy(_));
    +lastBuy(S);
    .print("I am going to buy shield! My money is ",M, " my max health is ", MyH);
    !do(buy(shield)).
    
+!buy:
    is_buy_attack_goal & money(M) & strength(MyS)
<- 
    .abolish(canBuy);
    .print("I am going to buy sabotageDevice! My money is ",M);
    !do(buy(sabotageDevice)).
 
+!attack(Entity):  
    true
<- 
    .print("I am going to attack an entity and its name is ", Entity);
    !do(attack(Entity)).
    
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
    position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
    ia.edge(MyV,Op,W) & energy(MyE) & costAttack(CostAttack) & MyE < W + CostAttack
<- 
    .print("I have chose to attack an enemy at ",Op, " but I don't have enough energy. I'm going to recharge firstly.I have ", MyE, " and I need ", W + CostAttack);
    !recharge.
    
+!followEnemy(Op): 
    position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
    ia.edge(MyV,Op,W) & energy(MyE) & costAttack(CostAttack) & MyE >= W + CostAttack
<- 
    .print("I have chose to attack an enemy at ",Op, " and I have enough energy. I have ", MyE, " and I need ", W + CostAttack);
    !goto(Op).
    
+!followEnemy(Op): 
    true
<- 
    .print("I have chose to attack an enemy at ",Op);
    !goto(Op).
    
+!random_walk: 
    is_good_destination(Op)
<- 
    .print("I have chose ",Op);
    !goto(Op).
    
+!random_walk: 
    true
<- 
    .print("I don't know where I'm going, so I'm going to recharge");
    !recharge.
            
+!clearDecision:
    true
 <-
    .abolish(nextStepSaboteurCounted(_));
    .abolish(nextStepSaboteur(_, _, _));
    .abolish(nextStepSaboteurAll(_));
    .abolish(numberWaits(_));
    +nextStepSaboteurAll(0);
    +numberWaits(0).
    
@nextStepSaboteur1[atomic]  
 +nextStepSaboteur(Ex, _, _):
    not nextStepSaboteurCounted(Ex) & nextStepSaboteurAll(X)
 <-
    +nextStepSaboteurCounted(Ex);
    -+nextStepSaboteurAll(X+1).
    
@nextStepSaboteur2[atomic]  
 +nextStepSaboteur(Ex, _, _):
    not nextStepSaboteurCounted(Ex) & not nextStepSaboteurAll(_)
 <-
    +nextStepSaboteurCounted(Ex);
    -+nextStepSaboteurAll(1).
    
@do0[atomic]
+!do(Act): 
    step(S) & stepDone(S)
<- 
    !clearDecision;
    .print("ERROR! I already performed an action for this step! ", S).
    
 // the following plans are used to send only one action each cycle
@do1[atomic]
+!do(attack(V)): 
    step(S) & .my_name(saboteur1)
<-
    !clearDecision; 
    .send(saboteur2,tell,nextStepSaboteur(saboteur1, V, S));
    .send(saboteur3,tell,nextStepSaboteur(saboteur1, V, S));
    .send(saboteur4,tell,nextStepSaboteur(saboteur1, V, S));
    -+stepDone(S);
    attack(V);
    !!synchronizeGraph.

@do2[atomic]
+!do(attack(V)): 
    step(S) & .my_name(saboteur2)
<-
    !clearDecision; 
    .send(saboteur3,tell,nextStepSaboteur(saboteur2, V, S));
    .send(saboteur4,tell,nextStepSaboteur(saboteur2, V, S));
    -+stepDone(S);
    attack(V);
    !!synchronizeGraph.

@do3[atomic]
+!do(attack(V)): 
    step(S) & .my_name(saboteur3)
<-
    !clearDecision; 
    .send(saboteur4,tell,nextStepSaboteur(saboteur3, V, S));
    -+stepDone(S);
    attack(V);
    !!synchronizeGraph.

@do4[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(saboteur1) 
<-
    !clearDecision;
    .send(saboteur2,tell,nextStepSaboteur(saboteur1, saboteur1Skip, S));
    .send(saboteur3,tell,nextStepSaboteur(saboteur1, saboteur1Skip, S));
    .send(saboteur4,tell,nextStepSaboteur(saboteur1, saboteur1Skip, S));
    .print("I'm saboteur1, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !!synchronizeGraph.
    
@do5[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(saboteur2) 
<-
    !clearDecision;
    .send(saboteur3,tell,nextStepSaboteur(saboteur2, saboteur2Skip, S));
    .send(saboteur4,tell,nextStepSaboteur(saboteur2, saboteur2Skip, S));
    .print("I'm saboteur2, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !!synchronizeGraph.

@do6[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(saboteur3) 
<-
    !clearDecision;
    .send(saboteur4,tell,nextStepSaboteur(saboteur3, saboteur3Skip, S)); 
    .print("I'm saboteur3, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !!synchronizeGraph.
    
@do7[atomic]
+!do(Act): 
    step(S)
<-
    !clearDecision; 
    .print("I'm saboteur4, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !!synchronizeGraph.

+!newPosition(V): 
    true 
<- 
    !newPositionRepairedGoal(V);
    !newPositionSwarmGoal(V);
    !!broadcastCurrentPosition(V);
    !!newPositionGettingAround(V).
    
+!newStepPosAction(S):  
    true 
<- 
    !testStrategy(S). 

+!walk_attack_area_search:
    get_vertex_to_go_attack_search(D, Path)
<-
    .print("I'm mode attack on search. I'm going to ", D, " using path: ", Path);
    !testWalkAttackArea(D);
    !gotoPathAttack(Path).
    
+!walk_attack_area_search: 
    true
<- 
    .print("I'm mode attack on search. I do not know any path.");
    !random_walk.

+!walk_attack_area:
    get_vertex_to_go_attack(D, Path)
<-
    .print("I'm mode attack on. I'm going to ", D, " using path: ", Path);
    !testWalkAttackArea(D);
    !gotoPathAttack(Path).
    
+!walk_attack_area: 
    true
<- 
    .print("I'm mode attack on. I do not know any path.");
    !random_walk.

+!testWalkAttackArea(D):
    visibleEntity(Entity, D, Team, _) & myTeam(MyTeam) & Team \== MyTeam
<-
    .print("I'm mode attack on. I can see ", Entity, " at ", D).
    
+!testWalkAttackArea(D):
    true
<-
    .print("I'm mode attack on. I do not see anyone at ", D).
    
+!gotoPathAttack([]):
    true
<-
    .print("I'm mode attack on. I do not know any path and I'm lost.");
    !random_walk.
    
+!gotoPathAttack([V|[]]):
    position(V)
<-
    .print("I'm mode attack on. I do not know any path and I'm lost two.");
    !random_walk.
    
+!gotoPathAttack([V|T]):
    position(V)
<-
    !gotoPathAttack(T).
    
+!gotoPathAttack([V|_]):
    true
<-
    .print("I'm mode attack on. My next step is ", V);
    !goto(V).

+!setEntityNewMaxStrength(Entity, MaxStrength):
    true
<-
    -entityStrength(Entity, _);
    +entityStrength(Entity, MaxStrength).
    
+!setEntityHealth(Entity, MaxHealth):
    true
<-
    -entityHealth(Entity, _);
    +entityHealth(Entity, MaxHealth).
    
@evaluateEntityNewMaxStrength1[atomic]
+!evaluateEntityNewMaxStrength(Entity):
    entityStrength(Entity, MaxStrength) & healthRequired(Current) & MaxStrength > Current -1
<-
    .print("New MaxStrength seen: ", MaxStrength, " setting healthRequired to ", MaxStrength +1);
    -+healthRequired(MaxStrength +1).
+!evaluateEntityNewMaxStrength(Entity): true <- true.

@evaluateEntityHealth1[atomic]
+!evaluateEntityHealth(Entity):
    entityHealth(Entity, MaxHealth) & strengthRequired(Current) & MaxHealth > Current & entityType(Entity, "Saboteur")
<-
    .print("New MaxHealth seen: ", MaxHealth, " setting strengthRequired to ", MaxHealth);
    -+strengthRequired(MaxHealth).
+!evaluateEntityHealth(Entity): true <- true.

+!processEntity(Entity):
    not friend(_, Entity, _)
<-
    !evaluateEntityNewMaxStrength(Entity);
    !evaluateEntityHealth(Entity).
+!processEntity(Entity): true <- true.
    
+!setStrategy(Strategy):
    true
<-
    .print("Received new strategy ", Strategy);
    -+strategy(Strategy).


+bestProbedVertex(_, _)[source(self)]: true <- true.    
+bestProbedVertex(V, Value):
    true
<-
    .print("Received best probed vertex from some explorer ", V, " with value ", Value);
    .abolish(bestProbedVertex(_, _));
    +bestProbedVertex(V, Value).
    
+!newPositionGettingAround(V):
    .my_name(saboteur4) & get_all_best_vertex(List) & .member(V, List) & not visitedBestVertex(V)
<-
    .print("Getting around arrived at ", V, " of ", List);
    +visitedBestVertex(V).
+!newPositionGettingAround(V): true <- true.

+!clearGettingAround:
    visitedBestVertex(_) & step(S) & stepCanGettingAround(StepGetting) & 
    S > StepGetting
<-
    .print("Clearing getting around!");
    .abolish(visitedBestVertex(_)).
+!clearGettingAround: true <- true.

+!testStrategy(S):
    not strategy(_) & S > 19
<-
    +strategy(1).
+!testStrategy(S): true <- true.
    
{ include("loadAgents.asl") }
