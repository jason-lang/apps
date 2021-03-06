{ include("mod.common.asl") }

/*
 * Depois de cada step a cada 15 steps calcula melhores áreas e notifica agentes
 * Tambem calcula pontos pivô (seria legal colocar isso em um artefato)
 * As áreas também poderiam ser colocadas em um artefato (artefato de exploração)
 * 
 * Novo algoritmo de areas, calcular todas as areas e ordenar, assim eh possivel pegar
 * diversas areas.
 * Nao calcular mais depois de probe todos os vertices.
 */

//Verify if the explorer is at an unprobed vertex, and he is the explorer with the highest priority when there are other explorers at the same vertex
is_probe_goal  :- not is_disabled & position(MyV) & not ia.probedVertex(MyV,_) & 
                  myTeam(MyTeam) & myNameInContest(MyName) & 
                  .my_name(MyAgentName) &
                  not (
                  	visibleEntity(Entity, MyV, MyTeam, normal) & 
                  	friend(AgentName, Entity, explorer, _) &
                  	Entity \== MyName & 
                  	priorityEntity(AgentName, MyAgentName)
                  ).
is_probe_goal(Op) :- not is_disabled & there_is_unprobed_vertex_next_to_mine(Op).

                  
/* 
 * #############################################################################
 * Check if there is some unprobed vertex around mine
 * #############################################################################
 */
 //Test if the vertex is not probed and there is other explorer there and also no one of the other explorers will go there in this step 
 //First try the vertices at the hill                       
there_is_unprobed_vertex_next_to_mine(Op) :- step(S) & position(MyV) & maxWeight(INF) & myTeam(MyTeam) & hill(Neighborhood) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		.member(V, Neighborhood) &
                           		not ia.probedVertex(V, _) &
                           		not (
                  					visibleEntity(Entity, V, MyTeam, normal) & 
                  					friend(_, Entity, explorer, _)
                  				) &
                  				not nextStepExplorer(_, V, S)
                           		, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_unprobed_vertex_next_to_mine(Op) :- position(MyV) & infinite(INF) & myTeam(MyTeam) & hill(Neighborhood) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		.member(V, Neighborhood) &
                           		not ia.probedVertex(V, _) &
                           		not (
                  					visibleEntity(Entity, V, MyTeam, normal) & 
                  					friend(_, Entity, explorer, _)
                  				) &
                  				not nextStepExplorer(_, V, S)
                           		, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
 
//Test if the vertex is not probed and there is other explorer there and also no one of the other explorers will go there in this step                        
there_is_unprobed_vertex_next_to_mine(Op) :- step(S) & position(MyV) & maxWeight(INF) & myTeam(MyTeam) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		not ia.probedVertex(V, _) &
                           		not (
                  					visibleEntity(Entity, V, MyTeam, normal) & 
                  					friend(_, Entity, explorer, _)
                  				) &
                  				not nextStepExplorer(_, V, S)
                           		, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_unprobed_vertex_next_to_mine(Op) :- position(MyV) & infinite(INF) & myTeam(MyTeam) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		not ia.probedVertex(V, _) &
                           		not (
                  					visibleEntity(Entity, V, MyTeam, normal) & 
                  					friend(_, Entity, explorer, _)
                  				) &
                  				not nextStepExplorer(_, V, S)
                           		, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
 
 /* TODO NÃO PROBE NOS MESMOS VERTICES DOS DEMAIS
//Test just if the vertex is not probed                        
there_is_unprobed_vertex_next_to_mine(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		not ia.probedVertex(V, _)
                           		, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_unprobed_vertex_next_to_mine(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		not ia.probedVertex(V, _)
                           		, Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
  */                          
                           
//Probe hills first
get_path_to_unprobed_probe(D, Path) :- 
 								not is_disabled & 
								position(MyV) &
								hill(Neighborhood) &
                                .setof(Vertex, 
                                		.member(Vertex, Neighborhood) &
                                        ia.probedVertex(Vertex,-1) & 
                                        not nextStepExplorer(_, Vertex, _)
                                , List) & 
                                not .empty(List) &
                                ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                Lenght > 2. 
                           
//Try to probe some far vertex, it is better
get_path_to_unprobed_probe(D, Path) :- 
 								not is_disabled & 
								position(MyV) &
                                .setof(Vertex, 
                                        ia.probedVertex(Vertex,-1) & 
                                        not nextStepExplorer(_, Vertex, _)
                                , List) & 
                                not .empty(List) &
                                ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                Lenght > 2. 




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
    step(S) & .count(nextStepExplorer(_, _, S), Number) &
	Number < NumberRequired &
	numberWaits(K)
<-  
    //.print("Waiting decision ", Number, "/", NumberRequired);
    .wait(50);
    -+numberWaits(K+1);
    !wait_and_select_goal.
+!wait_and_select_goal <- !select_goal.


/* TODO descomentar quando arrumado hard_deadline
+?count_received_nextStepExplorer(Number): 
	step(S) & .count(nextStepExplorer(_, _, S), Number).
+?count_received_nextStepExplorer(Number) <-
	.wait(35);
	?count_received_nextStepExplorer(Number).

+!wait_and_select_goal: 
	.my_name(MyName) & number_agents_higher_priority_same_type(MyName, Number)
<- 
	?count_received_nextStepExplorer(Number);
	!select_goal.
-!wait_and_select_goal[error(deadline_reached)] <- .print("Deadline reached"); !select_goal.
*/

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
		
+!select_goal: is_probe_goal & not is_leave_goal 
		<- !init_goal(probe).
		
+!select_goal : is_good_map_conquered <-
    .print("Good map conquered! Stopped!"); 
    !init_goal(recharge).
		
+!select_goal: is_probe_goal(Op) 
		<- !init_goal(goto(Op)).
+!select_goal: get_path_to_unprobed_probe(D, Path) 
		<- !init_goal(gotoPath(Path)).
+!select_goal: is_probe_goal //Probe even if I need to leave 
		<- !init_goal(probe).
		
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
+!select_goal: is_goal_hill_vertex(Op) 
		<- 
			.print("I have a hill vertex to go. I'm going to ", Op);
			!init_goal(goto(Op)).
+!select_goal: is_goal_hill_vertex(D, Path) 
		<- 
			.print("I have a hill vertex to go. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
			
+!select_goal : can_expand_to_hill(V) <-
    .print("I'm at a hill and I can expand to ", V); 
    !init_goal(goto(V)).
    
+!select_goal : is_at_aim_position_hill <-
    .print("Stop! Stand still! I'm settled at the hill!"); 
    !init_goal(recharge).
		
+!select_goal                  
		<- !init_goal(random_walk).
		
		
		
		
/*
 * Percept a new probed vertex and share with friends
 */
+probedVertex(V,Value) [source(percept)]:
    true
<- 
    .print("Vertex probed: ", V, " with value ", Value);
    ia.setVertexValue(V, Value);
    !broadcastProbe(V,Value).
+probedVertex(V,Value) [source(self)]: true <- -probedVertex(V,Value).
+probedVertex(V,Value): //Receive a new probed vertex by some friend
    true
<- 
	-probedVertex(V,Value);
    ia.setVertexValue(V, Value).
    
+!broadcastProbe(V,Value):
    .findall(Agent, friend(Agent, _, _, _), SetAgents)
<-
    .print("Sending probed vertex in broadcast ", V, " ", Value);
    .send(SetAgents, tell, probedVertex(V,Value)).
+!broadcastProbe(V,Value).

/*
 * These functions must be dependent of each kind of agent because they will
 * need to share some information with the other friends of the same kind
 */
+!do(Act): 
    step(S) & stepDone(S)
<- 
    .print("ERROR! I already performed an action for this step! ", S).
    
+!do(Act): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
    & is_disabled
<- 
	.send(SetAgents,tell,nextStepExplorer(MyName, none, S));
    !commitAction(Act);
    !!clearNextStepExplorer.

+!do(goto(V)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.send(SetAgents,tell,nextStepExplorer(MyName, V, S));
    !commitAction(goto(V));
    !!clearNextStepExplorer.

+!do(Act): 
    step(S) & position(V) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.send(SetAgents,tell,nextStepExplorer(MyName, V, S));
    !commitAction(Act);
    !!clearNextStepExplorer.

+!clearNextStepExplorer <-
	.abolish(nextStepExplorer(_, _, _)).
	
+!initSpecific.
+!processBeforeStep(S).
+!processAfterStep(S) <-
	!!calculateTotalSumVertices;
	!buildAreas(S).

/*
 * CALCULATE THE BEST PLACES
 */
+!buildAreas(S):
	S <= 125 & (not lastCalcCoverage(_) & S >= 13 | lastCalcCoverage(N) & S - N >= 13) & .my_name(MyName) & play(MyName,explorerLeader,"grMain")
<-	
	!determineHills;
	-+lastCalcCoverage(S).
+!buildAreas(S):
	S > 125 & .my_name(MyName) & play(MyName,explorerLeader,"grMain") & hill(_) &
	.findall(Agent, friend(Agent, _, _, _), SetAgents)
<-	
	.send(SetAgents, achieve, dismissHill).
+!buildAreas(S).


/* Update the sum of all vertices */
+!calculateTotalSumVertices:
    .my_name(MyName) & play(MyName,explorerLeader,"grMain") & ia.sumVertices(Total) &
    .findall(Agent, friend(Agent, _, _, _), SetAgents)
<-
    .print("Calculating the sum of all vertices: ", Total);
    !updateTotalSumVertices(Total);
    .send(SetAgents, achieve, updateTotalSumVertices(Total)).
+!calculateTotalSumVertices.