//If I'm disabled and there is a repairer at the same vertex, so I'm going to wait
is_wait_repair_goal(MyV) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.

//If I'm disabled and I'm not a repairer and there is a repairer at some adjacent vertex, so I'm going to wait
is_wait_repair_goal_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & not friend(_, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName &
               not (visibleEntity(Entity2, V, MyTeam, disabled) & Entity2 \== MyName & Entity2 \== Entity).
               
//If I'm disabled and I'm a repairer and there is an ENABLED repairer at some adjacent vertex, so I'm going to wait
is_wait_repair_goal_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & friend(_, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, normal) & friend(_, Entity, repairer, _) & Entity \== MyName &
               not (visibleEntity(Entity2, V, MyTeam, disabled) & Entity2 \== MyName & Entity2 \== Entity).
               
//If I'm disabled and I'm a repairer and there is an DISABLED repairer at some adjacent vertex, so I'm going to wait if he has more priority
is_wait_repair_goal_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & friend(MyAgentName, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(EntityAgentName, Entity, repairer, _) & Entity \== MyName &
               priorityEntity(EntityAgentName, MyAgentName) &
               not (visibleEntity(Entity2, V, MyTeam, disabled) & Entity2 \== MyName & Entity2 \== Entity).



//If I'm disabled and there is a repairer at some adjacent vertex, but the repairer is busy, so I'm going to there
is_goto_repair_goal_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               					ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName &
               					visibleEntity(Entity2, V, MyTeam, disabled) & Entity2 \== MyName & Entity2 \== Entity.




/*
 * When I'm disabled I can go to the nearest repairer
 */                            
get_vertex_to_go_repair(D, Path) :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
                                            .setof(V,
                                                visibleEntity(Entity, V, MyTeam, _) & 
                                                friend(_, Entity, repairer, _) & Entity \== MyName
                                            	,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_repair(D, Path) :- position(MyV)  & .my_name(MyAgentName) & .setof(V, 
                                                friend(AgentName, _, repairer, Id) &
                                                AgentName \== MyAgentName &
                                                ia.getAgentPosition(Id, V)
                                                , List
                                            ) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) & 
                                            Lenght > 2.
                                            
get_vertex_to_go_be_repaired_appointment(D, Path) :- position(MyV)  & .my_name(MyAgentName) & 
												acceptedAppointment[source(AgentName)] & friend(AgentName, _, repairer, Id) &
												ia.getAgentPosition(Id, D) &
												ia.shortestPath(MyV, D, Path, Lenght) &
                                            	Lenght > 2.

//Test if there is some repairer around me, so I don't need to call others
there_is_repairer_nearby(MyV) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.
there_is_repairer_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.
               