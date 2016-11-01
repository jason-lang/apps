there_is_repairer_same_vertex(RepairerName) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               							visibleEntity(Entity, MyV, MyTeam, _) & friend(RepairerName, Entity, repairer, _) & Entity \== MyName.


//If I'm disabled and there is a repairer at the same vertex, so I'm going to wait
is_wait_repair_goal(MyV) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               visibleEntity(Entity, MyV, MyTeam, _) & friend(RepairerSameVertex, Entity, repairer, _) & Entity \== MyName &
               not selfAppointment(_, RepairerSameVertex).

//If I'm disabled and I'm not a repairer and there is a repairer at some adjacent vertex, so I'm going to wait
is_wait_repair_goal_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & not friend(_, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(RepairerSameVertex, Entity, repairer, _) & Entity \== MyName &
               not (visibleEntity(Entity2, V, MyTeam, disabled) & Entity2 \== MyName & Entity2 \== Entity) &
               not selfAppointment(_, RepairerSameVertex).
               
//If I'm disabled and I'm a repairer and there is an ENABLED repairer at some adjacent vertex, so I'm going to wait
is_wait_repair_goal_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & friend(_, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, normal) & friend(RepairerSameVertex, Entity, repairer, _) & Entity \== MyName &
               not (visibleEntity(Entity2, V, MyTeam, disabled) & Entity2 \== MyName & Entity2 \== Entity) &
               not selfAppointment(_, RepairerSameVertex).
               
//If I'm disabled and I'm a repairer and there is an DISABLED repairer at some adjacent vertex, so I'm going to wait if he has more priority
is_wait_repair_goal_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & friend(MyAgentName, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(EntityAgentName, Entity, repairer, _) & Entity \== MyName &
               priorityEntity(EntityAgentName, MyAgentName) &
               not (visibleEntity(Entity2, V, MyTeam, disabled) & Entity2 \== MyName & Entity2 \== Entity) &
               not selfAppointment(_, EntityAgentName).



//If I'm disabled and there is a repairer at some adjacent vertex, but the repairer is busy, so I'm going to there
is_goto_repair_goal_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               					ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(RepairerSameVertex, Entity, repairer, _) & Entity \== MyName &
               					(
               						visibleEntity(Entity2, V, MyTeam, disabled) & Entity2 \== MyName & Entity2 \== Entity
               						|
               						canCome[source(RepairerSameVertex)]
               					) & 
               					not selfAppointment(_, RepairerSameVertex).



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
                                            	
get_vertex_to_go_be_repaired_appointment_self(D, Path) :- position(MyV)  & .my_name(MyAgentName) & 
												selfAppointment(AgentName, _) & friend(AgentName, _, repairer, Id) &
												ia.getAgentPosition(Id, D) &
												ia.shortestPath(MyV, D, Path, Lenght) &
                                            	Lenght > 2.

//Test if there is some repairer around me, so I don't need to call others
there_is_repairer_nearby(MyV) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.
there_is_repairer_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.
               
               
               
+!evaluateHealth(S):
	health(0) & hit(SHit) & S - SHit > 15 & not acceptedAppointment &
	there_is_repairer_same_vertex(RepairerSameVertex) &
	.setof(RepairerName, 
			friend(RepairerName, Entity, repairer, _) &
			RepairerName \== RepairerSameVertex,
           Options) & .length(Options, TotalOptions) & TotalOptions > 0 &
           .nth(math.random(TotalOptions), Options, Op)
<-
	-+hit(S);
	+selfAppointment(Op, RepairerSameVertex);
	.print("I'm at step ", S, " and I was hit at ", SHit, ". I'm choosing another repairer: ", Op).

+!evaluateHealth(S):
	.my_name(MyName) & position(Pos) & health(0) & hit(SHit) & S - SHit > 10 & not acceptedAppointment &
	not there_is_repairer_same_vertex(RepairerSameVertex) &
	play(RepairerLeader,repairerLeader,"grMain")
<-
	.print("I'm at step ", S, " and I was hit at ", SHit, ". I'm trying to ask help again. ");
	-+hit(S);
	.abolish(selfAppointment(_, _));
	.send(RepairerLeader, tell, hit(MyName, Pos)).
+!evaluateHealth(S).
               