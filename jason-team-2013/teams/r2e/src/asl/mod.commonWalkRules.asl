/*
 * Choose the vertex to go that it isn't visited by any of my friends. The vertex wasn't visited yet.
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.visitedVertex(V, _),Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.visitedVertex(V, _),Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * Choose the vertex to go that I know the cost of the edge
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
/*
 * By this time, I don't have any option to go!
 * I choose randomly
 */
is_good_destination(Op) :- position(MyV) & 
                           .setof(V, ia.edge(MyV,V,_), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
                           
                           
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
                                            	
                                            	
                                            	
                                            