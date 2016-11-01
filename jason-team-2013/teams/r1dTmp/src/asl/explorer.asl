{ include("mod.common.asl") }

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
is_probe_goal(Op) :- there_is_unprobed_vertex_next_to_mine(Op).

                  
/* 
 * #############################################################################
 * Check if there is some unprobed vertex around mine
 * #############################################################################
 */
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
                           
//Try to probe some far vertex, it is better
get_path_to_unprobed_probe(D, Path) :- 
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
		
+!select_goal: is_probe_goal & not is_leave_goal 
		<- !init_goal(probe).
+!select_goal: is_probe_goal(Op) 
		<- !init_goal(goto(Op)).
//TODO so chamar essas funcoes de probe se ainda tiverem vertices para serem dado probe
+!select_goal: get_path_to_unprobed_probe(D, Path) 
		<- !init_goal(gotoPath(Path)).
+!select_goal: is_probe_goal //Probe even if I need to leave 
		<- !init_goal(probe).
		
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

//!ffstart.

/* Plans */

+!ffstart : .my_name(explorer1) <- 
	.print("hello world.");
	makeArtifact(a0,"artifacts.Test",[10],Id);
	focus(Id);
	.send(coach, tell, meuArt(a0, Id));
	.print("Artifact created.");
	inc.
+!ffstart.
	
+count(X)
   <- .print("Count is ",X).

/*
+tick: artifact(a0, Id)
   <- 
   .print("Tick ");
   stopFocus(Id);
   ia.fastAbolish(_);
   .print("Stopped!!!!!!!!!!!!!!!");
   focus(Id). */