//agent explorer
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") } //YES, this is correct
{ include("commonRules_notRepairer.asl") }

//Verify if the explorer is at an unprobed vertex, and he is the explorer with the highest priority when there are other explorers at the same vertex
is_probe_goal  :- position(MyV) & not ia.probedVertex(MyV,_) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyAgentName) &
                  not (visibleEntity(Entity, MyV, MyTeam, normal) & friend(AgentName, Entity, explorer) & Entity \== MyName & priorityEntity(AgentName, MyAgentName)).


/*
 * THESE RULES REGARDS SECURITY REGIONS
 */
/* TRY TO PROBE THE GOOD AREA */
//These 4 first consider the decision of the others explorers
/* These 2 consider far plans
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & 
                                not there_is_enemy_at(V) &
                                not there_is_enemy_neighborhood(V) & 
                                not nextStepExplorer(_,V) & 
                                not (farVertexAim(_, Path) & .member(V, Path)) &
                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), 
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & 
                                not there_is_enemy_at(V) &
                                not there_is_enemy_neighborhood(V) & 
                                not nextStepExplorer(_,V) &
                                not (farVertexAim(_, Path) & .member(V, Path)) &
                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), 
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

//These 2, only consider the decision of the others explorers
/*
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, ia.edge(MyV,V,W) &
                            W \== INF & 
                            not ia.probedVertex(V, _) & 
                            not there_is_enemy_at(V) &
                            not there_is_enemy_neighborhood(V) &
                            not nextStepExplorer(_,V) & (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, ia.edge(MyV,V,W) & 
                            W \== INF & 
                            not ia.probedVertex(V, _) & 
                            not there_is_enemy_at(V) &
                            not there_is_enemy_neighborhood(V) & 
                            not nextStepExplorer(_,V) & (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
/* END PROBE GOOD AREA */

//These 4 first consider the decision of the others explorers
/* These 2 consider far plans
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & 
                                not there_is_enemy_at(V) & 
                                not there_is_enemy_neighborhood(V) &
                                not nextStepExplorer(_,V) & 
                                not (farVertexAim(_, Path) & .member(V, Path)), 
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & 
                                not ia.probedVertex(V, _) & 
                                not there_is_enemy_at(V) &
                                not there_is_enemy_neighborhood(V) & 
                                not nextStepExplorer(_,V) &
                                not (farVertexAim(_, Path) & .member(V, Path)), 
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

//These 2, only consider the decision of the others explorers
/*
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & 
                            not ia.probedVertex(V, _) & 
                            not there_is_enemy_at(V) &
                            not there_is_enemy_neighborhood(V) & 
                            not nextStepExplorer(_,V), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & 
                            W \== INF & 
                            not ia.probedVertex(V, _) & 
                            not there_is_enemy_at(V) &
                            not there_is_enemy_neighborhood(V) & 
                            not nextStepExplorer(_,V), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op). 
 /*
  * END SECURITY REGIONS
  */


/* TRY TO PROBE THE GOOD AREA */
//These 4 first consider the decision of the others explorers
/* These 2 consider far plans
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & 
                                not there_is_enemy_at(V) & not nextStepExplorer(_,V) & 
                                not (farVertexAim(_, Path) & .member(V, Path)) &
                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), 
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & 
                                not there_is_enemy_at(V) & not nextStepExplorer(_,V) &
                                not (farVertexAim(_, Path) & .member(V, Path)) &
                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), 
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

//These 2, only consider the decision of the others explorers
/*
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V) & not nextStepExplorer(_,V) & (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V) & not nextStepExplorer(_,V) & (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * The only differente is that I don't care for some enemy there. I ignore enemies.
 */                        
is_good_destination(Op) :- position(MyV) & maxWeight(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not nextStepExplorer(_,V) & (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) & allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not nextStepExplorer(_,V) & (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
/* END PROBE GOOD AREA */

//These 4 first consider the decision of the others explorers
/* These 2 consider far plans
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & 
                                not there_is_enemy_at(V) & not nextStepExplorer(_,V) & 
                                not (farVertexAim(_, Path) & .member(V, Path)), 
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & 
                                not there_is_enemy_at(V) & not nextStepExplorer(_,V) &
                                not (farVertexAim(_, Path) & .member(V, Path)), 
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

//These 2, only consider the decision of the others explorers
/*
 * Check if there is some good destination regarding to:
 * - it is an unprobed vertex
 * - there isn't dangerous enemy there
 * - there isn't any explorer friend going there
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V) & not nextStepExplorer(_,V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V) & not nextStepExplorer(_,V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * The only differente is that I don't care for some enemy there. I ignore enemies.
 */                        
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not nextStepExplorer(_,V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not nextStepExplorer(_,V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).                

/*
 * I have no options to go, because my explorer friends choose all of them, so I choose my option regarding to:
 * - the next option is an unprobed vertex
 * - there aren't dangerous enemies there
 */
is_good_destination_more(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination_more(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.probedVertex(V, _) & not there_is_enemy_at(V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * If I don't have options yet, so I choose the best probedVertex to go and that don't have enemy there.
 */
is_good_destination_more(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(Value, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,Value) & not there_is_enemy_at(V), SetValues)
                           & .max(SetValues, MaxValue)
                           & .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,MaxValue), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0
                           & .nth(math.random(TotalOptions), Options, Op).
is_good_destination_more(Op) :- position(MyV) & infinite(INF) &
                           .setof(Value, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,Value) & not there_is_enemy_at(V), SetValues)
                           & .max(SetValues, MaxValue)
                           & .setof(V, ia.edge(MyV,V,W) & W \== INF & ia.probedVertex(V,MaxValue), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0
                           & .nth(math.random(TotalOptions), Options, Op).

/*
 * By this time, I don't have any option to go!
 * I choose randomly
 */
is_good_destination_more(Op) :- position(MyV) &
                           .setof(V, ia.edge(MyV,V,_), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).                           

//Search some unprobed vertex with some Value
get_vertex_to_probe(List, Value) :- 
                                .setof(Vertex, 
                                        ia.probedVertex(V,Value) & 
                                        ia.edge(V, Vertex, _) & 
                                        not ia.probedVertex(Vertex,_) &
                                        not nextStepExplorer(_,Vertex) & 
                                        not (farVertexAim(_, Path) & .member(Vertex, Path)),
                                     List) & not .empty(List).


+!select_goal:
    not numberWaits(_)
<-
    +numberWaits(0);
    !select_goal.
    
+!select_goal:
    (numberWaits(K) & K >= 6) | (step(0) & not nextStepExplorerAll(10))
<-
    .print("I can't wait anymore!");
    -+numberWaits(0);
    -+nextStepExplorerAll(10);
    !select_goal.

+!select_goal:
    .my_name(explorer4) & nextStepExplorerAll(X) & X < 3 & numberWaits(K)
<-  
    .print("Waiting decision");
    .wait(150);
    -+numberWaits(K+1);
    !select_goal.
    
+!select_goal:
    .my_name(explorer3) & nextStepExplorerAll(X) & X < 2 & numberWaits(K)
<-  

    .print("Waiting decision");
    .wait(150);
    -+numberWaits(K+1);
    !select_goal.
    
+!select_goal:
    .my_name(explorer2) & nextStepExplorerAll(X) & X < 1 & numberWaits(K)
<-  

    .print("Waiting decision");
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

+!select_goal : waitABit <- !init_goal(recharge).
+!select_goal : is_probe_goal & not is_leave_goal & not is_disabled <- !init_goal(probe).
+!select_goal : returnTo(VOld) & position(VOld) <- -returnTo(_); !select_goal.
+!select_goal : returnTo(VOld) & position(VCurrent) & not ia.edge(VCurrent, VOld, _) <- -returnTo(_); !select_goal.
+!select_goal : returnTo(VOld) & is_disabled <- -returnTo(_); !select_goal.

+!select_goal : is_disabled <- !init_goal(walk_repair_forever_alone).

+!select_goal : no_way_to_go & is_leave_goal & not is_disabled <- !init_goal(survey).
+!select_goal : not is_almost_full_map & is_leave_goal & not is_disabled <- .print("Enemy here, leaving..."); !init_goal(searchBestVertex).

+!select_goal : returnTo(VOld) & not is_almost_full_map <- !init_goal(searchBestVertex).
+!select_goal : noMoreVertexToProbe & not is_disabled & is_survey_goal  <- !init_goal(survey).
+!select_goal : not noMoreVertexToProbe & not is_almost_full_map <- !init_goal(searchBestVertex).
+!select_goal : pathTogoSwarm(_, _) & not is_at_swarm_position & pathTogoSwarm(_, []) <- !cancelSwarmTravel; !select_goal.
+!select_goal : not is_almost_full_map & pathTogoSwarm(_, _) & not is_at_swarm_position <- !init_goal(walkSwarm).

+!select_goal : not is_disabled & is_good_map_conquered <-
    .print("Good map conquered!"); 
    !init_goal(recharge).
    
+!select_goal : not is_disabled & is_at_swarm_position_test & can_expand_to(V) <-
    .print("Stop! Stand still! I can expand to ", V); 
    !init_goal(goto(V)). 

+!select_goal : not is_disabled & is_at_swarm_position_test <-
    .print("Stop! Stand still!"); 
    !init_goal(recharge).
    
+!select_goal: noMoreVertexToProbe & not is_at_swarm_position & get_vertex_to_go_swarm(D, Path) <- !init_goal(gotoPathFastSwarm(Path)).

+!select_goal                  <- !init_goal(searchBestVertex).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
    true
<-
    +bestProbedVertex(unknown, 0);
    +bestVertex(11);
    +nextStepExplorerAll(0);
    
    +priorityEntity(explorer1, explorer2);
    +priorityEntity(explorer1, explorer3);
    +priorityEntity(explorer1, explorer4);
    
    +priorityEntity(explorer2, explorer3);
    +priorityEntity(explorer2, explorer4);
    
    +priorityEntity(explorer3, explorer4).


/* ROUTE */
+!searchBestVertex: 
    probeFarVertexPath(S, D, [])
<- 
    !cancelProbeRoute;
    !searchBestVertex.
    
+!searchBestVertex: 
    probeFarVertexPath(S, D, [H|T]) & position(H)
<- 
    -probeFarVertexPath(_, _, _);
    +probeFarVertexPath(S, D, T);
    !searchBestVertex.
    
+!searchBestVertex: 
    probeFarVertexPath(S, D, [H|T]) & position(MyV) & ia.edge(MyV,H,_)
<- 
    .print("PROBE I'm going to probe some far vertex at ", H);
    !goto(H).
    
+!searchBestVertex: 
    probeFarVertexPath(S, D, [H|T]) & position(MyV) & not ia.edge(MyV,H,_)
<- 
    .print("Ops! PROBE Wrong way to ",H, ". I'm going to select other vertex to go.");
    !cancelProbeRoute;
    !searchBestVertex.
/* END ROUTE */
   
+!searchBestVertex: 
    returnTo(VOld)
<- 
    .print("I'm returning to ",VOld);
    !goto(VOld).
    
+!searchBestVertex: 
    is_good_destination(Op)
<- 
    .print("I have chose ",Op);
    !goto(Op).

+!searchBestVertex:
    not is_probe_goal
<-
    .print("I don't know where I'm going, so I'm going to choose a far unprobed vertex to probe"); 
    !chooseVertexToProbe;
    !searchBestVertex.
    
+!searchBestVertex: 
    is_good_destination_more(Op)
<-
    .print("It is not time to choose a vertex to probe, so I'm going to choose other alternative..."); 
    !goto(Op).
    
+!searchBestVertex: 
    true
<-
    .print("I don't know what to do, so I'm going to recharge."); 
    !recharge.
    
-!searchBestVertex: 
    is_good_destination_more(Op)
<-
    .print("I don't know any unprobed vertex to probe, so I'm going to choose other alternative..."); 
    !goto(Op).
    
-!searchBestVertex: 
    true
<-
    .print("I don't know any unprobed vertex to probe, so I'm going to recharge..."); 
    !recharge.
    
+!probe:
    bestVertex(Value)
<- 
   .print("Probing my location. I'm trying to find a vertex of value ", Value);
   !do(probe);
   !updateBestVertex;
   !checkBestVertex.
   
+!probe:
    true
<- 
   +bestVertex(11);
   !probe.

+!updateBestVertex:
    lastProbed(V,Value) & maxProbedVertex(VBest, ValueBest) & Value > ValueBest
<-
    -+maxProbedVertex(V,Value).
    
+!updateBestVertex:
    lastProbed(V,Value) & not maxProbedVertex(_, _)
<-
    +maxProbedVertex(V,Value).
+!updateBestVertex: true <- true.

+!checkBestVertex:
    maxProbedVertex(V,Value) & bestVertex(Value)
<-
    .print("I found the best vertex here!!!!").
+!checkBestVertex: true <- true.
    
+!testingNewTargets:
    bestVertex(Value)
<-
    .print("Now I'm looking for a vertex of value ", Value).
    
+!checkBestVertex: true <- true.
            
//Percepts
@probedVertex1[atomic]  
+probedVertex(V,Value) [source(percept)]: //my current probed vertex is less good than my last one
    lastProbed(VOld,ValueOld) & ValueOld > Value & lastPosition(VBefore)
<- 
    .print("Vertex probed: ", V, " with value ", Value, " is less good than my last one ", VOld, " with the value ", ValueOld);
    ia.setVertexValue(V, Value);
    !broadcastProbe(V,Value);
    !evaluateProbedVertex(V, Value);
    !computeFarProbedVertex(V).
    
@probedVertex2[atomic]
+probedVertex(V,Value) [source(percept)]:
    lastProbed(VOld,ValueOld)
<- 
    .print("Vertex probed: ", V, " with value ", Value);
    -lastProbed(VOld,ValueOld);
    +lastProbed(V,Value);
    ia.setVertexValue(V, Value);
    !broadcastProbe(V,Value);
    !evaluateProbedVertex(V, Value);
    !computeFarProbedVertex(V).
    
@probedVertex3[atomic]
+probedVertex(V,Value) [source(percept)]:
    true
<- 
    .print("Vertex probed: ", V, " with value ", Value);
    +lastProbed(V,Value);
    ia.setVertexValue(V, Value);
    !broadcastProbe(V,Value);
    !evaluateProbedVertex(V, Value);
    !computeFarProbedVertex(V).
    
+probedVertex(V,Value) [source(self)]: true <- -probedVertex(V,Value).
@probedVertexBroadcast[atomic]
+probedVertex(V,Value):
    true
<- 
    ia.setVertexValue(V, Value);
    !evaluateProbedVertex(V, Value);
    -probedVertex(V,Value);
    !computeFarProbedVertex(V).
    
+!broadcastProbe(V,Value):
    true
<-
    .print("Sending probed vertex in broadcast ", V, " ", Value);
    .broadcast(tell,probedVertex(V,Value)).
+!broadcastProbe(V,Value): true <- true.

+!evaluateProbedVertex(V, Value):
    bestProbedVertex(_, BestValue) & Value > BestValue & .my_name(explorer4)
<-
    .print("New best probed vertex found: ", V, " ", Value);
    .send(saboteur1, tell, bestProbedVertex(V, Value));
    .send(saboteur2, tell, bestProbedVertex(V, Value));
    .send(saboteur3, tell, bestProbedVertex(V, Value));
    .send(saboteur4, tell, bestProbedVertex(V, Value));
    -+bestProbedVertex(V, Value).
+!evaluateProbedVertex(V, Value):
    not bestProbedVertex(_, _) & .my_name(explorer4)
<-
    .print("New best probed vertex found: ", V, " ", Value);
    .send(saboteur1, tell, bestProbedVertex(V, Value));
    .send(saboteur2, tell, bestProbedVertex(V, Value));
    .send(saboteur3, tell, bestProbedVertex(V, Value));
    .send(saboteur4, tell, bestProbedVertex(V, Value));
    +bestProbedVertex(V, Value).
+!evaluateProbedVertex(V, Value):
    bestProbedVertex(_, BestValue) & Value > BestValue
<-
    .print("New best probed vertex found: ", V, " ", Value);
    -+bestProbedVertex(V, Value).
+!evaluateProbedVertex(V, Value):
    not bestProbedVertex(_, _)
<-
    .print("New best probed vertex found: ", V, " ", Value);
    +bestProbedVertex(V, Value).
+!evaluateProbedVertex(V, Value): true <- true. 
 
+!clearDecision:
    true
 <-
    .abolish(nextStepExplorerCounted(_));
    .abolish(nextStepExplorer(_, _));
    .abolish(nextStepExplorerAll(_));
    .abolish(numberWaits(_));
    +nextStepExplorerAll(0);
    +numberWaits(0).
    
@nextStepExplorer1[atomic]  
 +nextStepExplorer(Ex, _):
    not nextStepExplorerCounted(Ex) & nextStepExplorerAll(X)
 <-
    +nextStepExplorerCounted(Ex);
    -+nextStepExplorerAll(X+1).
    
@do0[atomic]
+!do(Act): 
    step(S) & stepDone(S)
<- 
    !clearDecision;
    .print("ERROR! I already performed an action for this step! ", S).
    
 // the following plans are used to send only one action each cycle
@do1[atomic]
+!do(goto(V)): 
    step(S) & .my_name(explorer1)
<- 
    .send(explorer2,tell,nextStepExplorer(explorer1, V));
    .send(explorer3,tell,nextStepExplorer(explorer1, V));
    .send(explorer4,tell,nextStepExplorer(explorer1, V));
    -+stepDone(S);
    goto(V);
    !clearDecision;
    !!synchronizeGraph.

@do2[atomic]
+!do(goto(V)): 
    step(S) & .my_name(explorer2)
<- 
    .send(explorer3,tell,nextStepExplorer(explorer2, V));
    .send(explorer4,tell,nextStepExplorer(explorer2, V));
    -+stepDone(S);
    goto(V);
    !clearDecision;
    !!synchronizeGraph.

@do3[atomic]
+!do(goto(V)): 
    step(S) & .my_name(explorer3)
<- 
    .send(explorer4,tell,nextStepExplorer(explorer3, V));
    -+stepDone(S);
    goto(V);
    !clearDecision;
    !!synchronizeGraph.

@do4[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(explorer1) 
<-
    .send(explorer2,tell,nextStepExplorer(explorer1, V));
    .send(explorer3,tell,nextStepExplorer(explorer1, V));
    .send(explorer4,tell,nextStepExplorer(explorer1, V));
    .print("I'm explorer1, and I'm notifying my friends.");
    -+stepDone(S); 
    Act;
    !clearDecision;
    !!synchronizeGraph.
    
@do5[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(explorer2) 
<-
    .send(explorer3,tell,nextStepExplorer(explorer2, V));
    .send(explorer4,tell,nextStepExplorer(explorer2, V));
    .print("I'm explorer2, and I'm notifying my friends.");
    -+stepDone(S); 
    Act;
    !clearDecision;
    !!synchronizeGraph.

@do6[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(explorer3) 
<-
    .send(explorer4,tell,nextStepExplorer(explorer3, V)); 
    .print("I'm explorer3, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !clearDecision;
    !!synchronizeGraph.
    
@do7[atomic]
+!do(Act): 
    step(S)
<- 
    .print("I'm explorer4, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !clearDecision;
    !!synchronizeGraph.

+!newPosition(V): 
    true 
<- 
    !newPositionRepairedGoal(V);
    !newPositionProbeGoal(V);
    !newPositionSwarmGoal(V);
    !!broadcastCurrentPosition(V).
    
/* EXPLORE FAR VERTEX */
+!chooseVertexToProbe:
    bestProbedVertex(_, BestVertexValue)
<-
    .abolish(probeFarVertexPath(_, _, _));
    !chooseVertexToProbe(BestVertexValue);
    ?probeFarVertexPath(S, D, Path);
    !notifyFriendsFarVertex;
    .print("I chose to probe the vertex ", D, " from ", S, " Path: ", Path).
    
+!chooseVertexToProbe(1):
    not get_vertex_to_probe(List, 1)
<-
    true.
    
+!chooseVertexToProbe(Value):
    not get_vertex_to_probe(List, Value)
<-
    !chooseVertexToProbe(Value-1).
    
+!chooseVertexToProbe(Value):
    get_vertex_to_probe(List, Value)
<-
    .print("I have this vertices with value ", Value, " to test ", List);
    !tryPathToProbeClosest(List).
    
+!tryPathToProbeClosest(List):
    position(S)
<-
    .print("PROBE CLOSEST Calculating the best vertex of ", List, " to probe.");
    ia.shortestPathDijkstraComplete(S, List, D, Path, Lenght);
    Lenght >= 2;
    +probeFarVertexPath(S, D, Path);
    .print("PROBE CLOSEST The best vertex to probe of ",List," is ", D, " with the path ", Path, " and lenght ", Lenght).
    
-!tryPathToProbeClosest(List):
    true
<-
    .print("PROBE CLOSEST Some problem with the list ", List).
    
-!chooseVertexToProbe(Value):
    true
<-
    !chooseVertexToProbe(Value-1).
    
+!tryPathToProbe([H|T]):
    true
<-
    !probeFarVertex(H).
    
-!tryPathToProbe([H|T]):
    not .empty(T)
<-
    !tryPathToProbe(T).

+!probeFarVertex(D):
    position(S)
<-
    !calculeShortestPath(S, D, Path, Lenght);
    Lenght >= 2;
    +probeFarVertexPath(S, D, Path).
    
+!cancelProbeRoute:
    probeFarVertexPath(_, V, _)
<-
    .print("Cancel far vertex to probe... ", V);
    .abolish(probeFarVertexPath(_, _, _));
    !notifyFriendsCancelFarVertex.
    
+!cancelProbeRoute(V):
    probeFarVertexPath(_, V, _)
<-
    !cancelProbeRoute.
+!cancelProbeRoute(V): true <- true.
    
+!computeFarProbedVertex(V):
    probeFarVertexPath(_, V, _)
<-
    !cancelProbeRoute(V).
+!computeFarProbedVertex(V): true <- true.
    
+gotoVertexRepair(_, _, _):
    probeFarVertexPath(_, _, _)
<-
    !cancelProbeRoute.
    
+!newPositionProbeGoal(V): 
    probeFarVertexPath(S, D, [V|[]])
<- 
    .print("PROBE I arrived at ", V).
    
+!newPositionProbeGoal(V):
    probeFarVertexPath(S, D, [V|T])
<- 
    .abolish(probeFarVertexPath(_, _, _));
    +probeFarVertexPath(S, D, T);
    .print("PROBE I'm at ", V, ". My travel is: ", T).

+!newPositionProbeGoal(V): true <- true.

+!notifyFriendsCancelFarVertex:
    .my_name(explorer1)
<-
    .send(explorer2, untell, farVertexAim(_, _));
    .send(explorer3, untell, farVertexAim(_, _));
    .send(explorer4, untell, farVertexAim(_, _)).
    
+!notifyFriendsCancelFarVertex:
    .my_name(explorer2)
<-
    .send(explorer1, untell, farVertexAim(_, _));
    .send(explorer3, untell, farVertexAim(_, _));
    .send(explorer4, untell, farVertexAim(_, _)).
    
+!notifyFriendsCancelFarVertex:
    .my_name(explorer3)
<-
    .send(explorer1, untell, farVertexAim(_, _));
    .send(explorer2, untell, farVertexAim(_, _));
    .send(explorer4, untell, farVertexAim(_, _)).
    
+!notifyFriendsCancelFarVertex:
    .my_name(explorer4)
<-
    .send(explorer1, untell, farVertexAim(_, _));
    .send(explorer2, untell, farVertexAim(_, _));
    .send(explorer3, untell, farVertexAim(_, _)).

+!notifyFriendsFarVertex:
    probeFarVertexPath(S, D, Path) & .my_name(explorer1)
<-
    .send(explorer2, tell, farVertexAim(D, Path));
    .send(explorer3, tell, farVertexAim(D, Path));
    .send(explorer4, tell, farVertexAim(D, Path)).
    
+!notifyFriendsFarVertex:
    probeFarVertexPath(S, D, Path) & .my_name(explorer2)
<-
    .send(explorer1, tell, farVertexAim(D, Path));
    .send(explorer3, tell, farVertexAim(D, Path));
    .send(explorer4, tell, farVertexAim(D, Path)).
    
+!notifyFriendsFarVertex:
    probeFarVertexPath(S, D, Path) & .my_name(explorer3)
<-
    .send(explorer1, tell, farVertexAim(D, Path));
    .send(explorer2, tell, farVertexAim(D, Path));
    .send(explorer4, tell, farVertexAim(D, Path)).
    
+!notifyFriendsFarVertex:
    probeFarVertexPath(S, D, Path) & .my_name(explorer4)
<-
    .send(explorer1, tell, farVertexAim(D, Path));
    .send(explorer2, tell, farVertexAim(D, Path));
    .send(explorer3, tell, farVertexAim(D, Path)).
    
+farVertexAim(D, Path)[source(AgentName)]:
    true
<-
    .print("farVertexAim received from ", AgentName, " ", D, " Path: ", Path).
/* END EXPLORE FAR VERTEX */
    
+!newStepPosAction(S):
    .my_name(explorer3) & not ia.thereIsUnprobedVertex & not noMoreVertexToProbe
<-
    +noMoreVertexToProbe;
    !!tryProposeBestCoverage(S).
    
+!newStepPosAction(S): //for security
    .my_name(explorer3) & ia.thereIsUnprobedVertex & noMoreVertexToProbe
<-
    -noMoreVertexToProbe;
    !!tryProposeBestCoverage(S).
    
+!newStepPosAction(S):
    .my_name(explorer3)
<-
    !!tryProposeBestCoverage(S).

+!newStepPosAction(S):
    not ia.thereIsUnprobedVertex & not noMoreVertexToProbe
<-
    +noMoreVertexToProbe.
    
+!newStepPosAction(S):
    ia.thereIsUnprobedVertex & noMoreVertexToProbe
<-
    -noMoreVertexToProbe.

+!newStepPosAction(S):
    true
<-
    true.
    
+!tryProposeBestCoverage(S):    
    lastCalcCoverage(N) & S - N >= 15 & .my_name(explorer3) & S < 100
<-
    -+lastCalcCoverage(S);
    .print("COVERAGE Calculing the best coverage...");
    ia.bestCoverage(1, BestVertex, BestValue);
    ia.neighborhood(BestVertex, 2, Neighborhood);
    .print("COVERAGE Result was... BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !decideBestCoverageProposal(BestVertex, BestValue, Neighborhood).
     
+!tryProposeBestCoverage(S):    
    lastCalcCoverage(N) & S - N >= 15 & .my_name(explorer3)
<-
    -+lastCalcCoverage(S);
    .print("COVERAGE Calculing the best coverage...");
    ia.bestCoverage(2, BestVertex, BestValue);
    ia.neighborhood(BestVertex, 2, Neighborhood);
    .print("COVERAGE Result was... BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !decideBestCoverageProposal(BestVertex, BestValue, Neighborhood).
    
+!tryProposeBestCoverage(S):    
    not lastCalcCoverage(_)
<- 
    +lastCalcCoverage(0);
    !tryProposeBestCoverage(S).
    
+!tryProposeBestCoverage(S): true <- true.
-!tryProposeBestCoverage(S):    
    true 
<- 
    .print("COVERAGE Something wrong...").
    
    
//Calc the second best place
+!tryProposeBestCoverageTwo(S, BestVertexCurrent):  
    .my_name(explorer3) & S < 100
<-
    .print("COVERAGE TWO Calculing the best coverage...");
    ia.bestCoverageIgnoringVertex(1, BestVertexCurrent, BestVertex, BestValue);
    ia.neighborhood(BestVertex, 2, Neighborhood);
    .print("COVERAGE TWO Result was... BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !decideBestCoverageProposalTwo(BestVertex, BestValue, Neighborhood).
     

+!tryProposeBestCoverageTwo(S, BestVertexCurrent):  
    .my_name(explorer3)
<- 
    .print("COVERAGE TWO Calculing the best coverage...");
    ia.bestCoverageIgnoringVertex(2, BestVertexCurrent, BestVertex, BestValue);
    ia.neighborhood(BestVertex, 2, Neighborhood);
    .print("COVERAGE TWO Result was... BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !decideBestCoverageProposalTwo(BestVertex, BestValue, Neighborhood).
    
+!decideBestCoverageProposalTwo(BestVertex, BestValue, Neighborhood): //the second good place
    true
<-
    .send(explorer4, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(sentinel3, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(sentinel4, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(inspector3, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(inspector4, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(repairer3, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    !callSaboteursTwo(BestVertex, BestValue, Neighborhood);
    !setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood);
    .print("COVERAGE DECISION RESULT TWO: BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood).

+!callSaboteursTwo(BestVertex, BestValue, Neighborhood):
    not lastCallSab(_)
<-
    .print("ERROR CHANGING SABOTEURS AND REPAIRERS!");
    +lastCallSab(0);
    !callSaboteursTwo(BestVertex, BestValue, Neighborhood).
    
+!callSaboteursTwo(BestVertex, BestValue, Neighborhood):
    lastCallSab(Last) & Last >= 8
<-
    .print("ERROR CHANGING SABOTEURS AND REPAIRERS TWO!");
    .abolish(lastCallSab(_));
    +lastCallSab(0);
    !callSaboteursTwo(BestVertex, BestValue, Neighborhood).
    
+!callSaboteursTwo(BestVertex, BestValue, Neighborhood):
    lastCallSab(Last) & Last >= 4
<-
    .print("Changing saboteurs and repairers ONE/TWO");
    -+lastCallSab(Last+1);
    .send(saboteur3, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(saboteur4, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(repairer4, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood)).
    
+!callSaboteursTwo(BestVertex, BestValue, Neighborhood):
    lastCallSab(Last)
<-
    .print("Changing saboteurs and repairers ONE/ONE");
    -+lastCallSab(Last+1);
    .send(saboteur1, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(saboteur2, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(repairer2, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood)).
    
+!decideBestCoverageProposal(BestVertex, BestValue, Neighborhood):
    true
<-
    .send(explorer1, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(explorer2, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(sentinel1, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(sentinel2, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(inspector1, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(inspector2, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(repairer1, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    !callSaboteursOne(BestVertex, BestValue, Neighborhood);
    .abolish(bestCoverageProposal(_, _, _, _));
    .print("COVERAGE DECISION RESULT ONE: BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !tryProposeBestCoverageTwo(S, BestVertex).
    
+!callSaboteursOne(BestVertex, BestValue, Neighborhood):
    not lastCallSab(_)
<-
    +lastCallSab(0);
    !callSaboteursOne(BestVertex, BestValue, Neighborhood).
    
+!callSaboteursOne(BestVertex, BestValue, Neighborhood):
    lastCallSab(Last) & Last >= 8
<-
    .abolish(lastCallSab(_));
    +lastCallSab(0);
    !callSaboteursOne(BestVertex, BestValue, Neighborhood).
    
+!callSaboteursOne(BestVertex, BestValue, Neighborhood):
    lastCallSab(Last) & Last >= 4
<-
    .print("Changing saboteurs and repairers ONE");
    .send(saboteur1, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(saboteur2, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(repairer2, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood)).
    
+!callSaboteursOne(BestVertex, BestValue, Neighborhood):
    lastCallSab(Last)
<-
    .print("Changing saboteurs and repairers TWO");
    .send(saboteur3, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(saboteur4, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood));
    .send(repairer4, achieve, setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood)).
    
//Help friends
+!calculeSomePathForMe(S, List)[source(AgentName)]:
    .my_name(explorer3)
<-
    .print("SWARM: Helping my friend! ", AgentName);
    ia.shortestPathDijkstraComplete(S, List, D, Path, Lenght);
    .print("SWARM: Helping my friend! ",AgentName," Result: Best vertex to go is ", S, " -> ", D, " with path: ", Path, " and lenght: ", Lenght);
    .send(AgentName, achieve, prepareTogoSwarmPlace(Path, D)).
    
-!calculeSomePathForMe(S, List)[source(AgentName)]:
    true
<-
    .print("SWARM: I can not help my friend! ", AgentName).
    
+!processEntity(Entity): true <- true.

{ include("loadAgents.asl") }
