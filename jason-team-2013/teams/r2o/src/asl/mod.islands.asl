there_is_enemy_in_island(V, VerticesIsland, ValueIsland) :-  
						    aimVertex(V, island, island(V, VerticesIsland, ValueIsland)) & 
							position(V) & myTeam(MyTeam) & 
							.member(Vtest,VerticesIsland) & ia.vertex(Vtest, Team) & Team \== MyTeam.
							
island_belongs_to_us(V) :- aimVertex(V, island, island(V, VerticesIsland, ValueIsland)) & 
							myTeam(MyTeam) & 
							not (
								.member(Vtest,VerticesIsland) &
								ia.vertex(Vtest, Team) & Team \== MyTeam
							).


/* Protect island */
is_keep_goal_island_enemy(Entity) :- not is_disabled & is_free_to_walk & position(MyV) & step(S) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam &
							   aimVertex(_, island, island(_, VerticesIsland, _)) & .member(MyV,VerticesIsland).
                               
there_is_enemy_nearby_island_geral(Op) :- step(S) & not is_disabled & is_free_to_walk & position(MyV) & myTeam(MyTeam) & aimVertex(_, island, island(_, VerticesIsland, _)) &
									.member(MyV,VerticesIsland) &
		                           .setof(V, ia.edge(MyV,V,_) & 
		                           			.member(V,VerticesIsland) &
		                                    visibleEntity(Entity, V, Team, normal) & 
		                                    Team \== MyTeam & 
		                                    not there_is_friend_at(V), Options
		                           )
		                           & .length(Options, TotalOptions) & TotalOptions > 0 &
		                           .nth(math.random(TotalOptions), Options, Op).

there_is_enemy_nearby_island_geral(Op) :- step(S) & not is_disabled & is_free_to_walk & position(MyV) & myTeam(MyTeam) & aimVertex(_, island, island(_, VerticesIsland, _)) &
									.member(MyV,VerticesIsland) &
		                           .setof(V, ia.edge(MyV,V,_) & 
		                           		    .member(V,VerticesIsland) &
		                                    ia.vertex(V, Team) & 
		                                    Team \== none & 
		                                    Team \== MyTeam &
		                                    not there_is_friend_at(V), Options
		                           )
		                           & .length(Options, TotalOptions) & TotalOptions > 0 &
		                           .nth(math.random(TotalOptions), Options, Op).
		                           
get_vertex_to_go_attack_search_island_geral(D, Path) :- not is_disabled & is_free_to_walk & position(MyV) & aimVertex(_, island, island(_, VerticesIsland, _)) &
											.member(MyV,VerticesIsland) &
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                .member(V,VerticesIsland) &
                                                not there_is_friend_at(V) 
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.
/* End protect island */

+!determineIslands:
	.count(play(Ag,_,"grPivots"), NumberIslands)
<-
	.print("Calculating islands");
    ia.getIslands(NumberIslands, List);
    .abolish(islands(_, _));
    +islands(List);
    .print("#ISLANDS# ", List);
    !distributeAimVertices.
    
@gotoIslandVertex0[atomic]
+!gotoIslandVertex(V, Description):
	aimVertex(CurrentV, _, _) & CurrentV \== V &
	calledSaboteur(_) & play(SaboteurLeader,saboteurLeader,"grMain")
<-
	.abolish(aimVertex(_,_,_));
	+aimVertex(V, island, Description);
	.abolish(calledSaboteur(_));
	.send(SaboteurLeader, tell, islandIsFree);
	.print("I got a new island! My previous place is free. ", V).
    
@gotoIslandVertex[atomic]
+!gotoIslandVertex(V, Description) 
<-
	.abolish(aimVertex(_,_,_));
	+aimVertex(V, island, Description).
	
	
+!testCleanIsland:
	there_is_enemy_in_island(V, VerticesIsland, ValueIsland) & not calledSaboteur(V) &
	play(SaboteurLeader,saboteurLeader,"grMain") & step(S) & S > 200
<-
	.send(SaboteurLeader, tell, enemyAtIsland(V, VerticesIsland, ValueIsland));
	+calledSaboteur(V);
	.print("There is some enemy in the island! ", V).
+!testCleanIsland:
	island_belongs_to_us(V) & calledSaboteur(V) &
	play(SaboteurLeader,saboteurLeader,"grMain") 
<-
	.abolish(calledSaboteur(_));
	.send(SaboteurLeader, tell, islandIsFree);
	.print("The island belongs to us! ", V).
+!testCleanIsland.


+islandIsFree[source(Agent)] <-
    .abolish(chosenIslandToProtect(_, _, Agent));
	.abolish(enemyAtIsland(_, _, _)[source(Agent)]);
	.abolish(islandIsFree[source(Agent)]);
	.print("The agent ", Agent, " has its island clean").
	
+enemyAtIsland(V, VerticesIsland, Value)[source(Agent)] <-
	.print("There is some enemy at the island ", V, " ", VerticesIsland, " protected by ", Agent).

