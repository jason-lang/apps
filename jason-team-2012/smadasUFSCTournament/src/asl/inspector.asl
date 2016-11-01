//agent inspector
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_notRepairer.asl") }

/*
 * the inspect goal is enabled when:
 * - there is an enemy at the same vertex than an inspector
 * - the enemy wasn't inspected before OR the interval between the last inspected and the current step is great than the "time between inspections"
 * - if I have more priority than other inspectors at the same vertex
 */
is_inspect_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, V, Team, _) & Team \== MyTeam & ia.edge(MyV,V,_) 
                  & need_inspect(Entity) &
                  i_have_more_priority.
                  
is_inspect_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, _) & Team \== MyTeam 
                  & need_inspect(Entity) &
                  i_have_more_priority.
                  
need_inspect(Entity) :- timeBetweenInspect(Time) & step(S) & 
                        (
                            not entityType(Entity, _) 
                            | 
                            entityType(Entity, "Saboteur") & 
                            lastInspectEntity(Entity, SInspect) & 
                            S - SInspect > Time
                        ).
                        
                        
is_inspect_goal_swarm :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, V, Team, _) & Team \== MyTeam & ia.edge(MyV,V,_) 
                        & need_inspect_swarm(Entity) & not (
                            visibleEntity(Entity, MyV, Team, normal) &
                            Team \== MyTeam &
                            entityType(Entity, "Saboteur")
                        ).
                  
is_inspect_goal_swarm :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, _) & Team \== MyTeam 
                        & need_inspect_swarm(Entity) & not (
                            visibleEntity(Entity, MyV, Team, normal) &
                            Team \== MyTeam &
                            entityType(Entity, "Saboteur")
                        ).
                  
need_inspect_swarm(Entity) :- timeBetweenInspect(Time) & step(S) & 
                                lastInspectEntity(Entity, SInspect) & S - SInspect > Time.
                        
                  
//Test if there is other inspectors at the same vertex and I have the highest priority
i_have_more_priority :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyAgentName) &
                  not (visibleEntity(Entity, MyV, MyTeam, normal) & friend(AgentName, Entity, inspector) & Entity \== MyName & priorityEntity(AgentName, MyAgentName)).

                       
/*
 * This rule check if there is an adjacent vertex that is dominated by the enemy team, but it is possible that don't have any enemy there.
 * I only choose the vertices than I didn't visit in some interval of steps
 * I may have a set of options, so I choose randomly between all options
 */
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF)
                            & timeBetweenInspect(Time) & step(S) &
                           .setof(
                                V, 
                                    ia.edge(MyV,V,W) & W \== INF & ia.vertex(V, Team) & Team \== none & Team \== MyTeam 
                                    & not there_is_enemy_at(V)
                                    & (not ia.visitedVertex(V, _) | myVisitedVertex(V, SVisit) & S - SVisit > Time),
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_enemy_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF)
                            & timeBetweenInspect(Time) & step(S) &
                           .setof(
                                V, 
                                    ia.edge(MyV,V,W) & W \== INF & ia.vertex(V, Team) & Team \== none & Team \== MyTeam
                                    & not there_is_enemy_at(V)
                                    & (not ia.visitedVertex(V, _) | myVisitedVertex(V, SVisit) & S - SVisit > Time),
                                Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
                           
get_vertex_to_go_inspect_search(D, Path) :- position(MyV) & myTeam(MyTeam) & allowedArea(NeighborhoodOutside, NeighborhoodInside) & 
                                            .setof(V,
                                                visibleEntity(Entity, V, Team, _) & 
                                                MyTeam \== Team &
                                                not entityType(Entity, _) &
                                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside))
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_inspect_search(D, Path) :- position(MyV) & allowedArea(NeighborhoodOutside, NeighborhoodInside) & 
                                            .setof(V,
                                                ia.visibleEnemy(Entity, V) & 
                                                not entityType(Entity, _) &
                                                (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside))
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.
                           
noMoreVertexToProbe :- true.
                           
/* The sequence of the priority plans */
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

+!select_goal : is_disabled <- !init_goal(walk_repair_forever_alone).

+!select_goal : is_inspect_goal & not is_disabled <- !init_goal(inspect).
+!select_goal : no_way_to_go & (there_is_enemy_nearby(Op) | is_leave_goal) & not is_disabled <- !init_goal(survey).
+!select_goal : there_is_enemy_nearby(Op) & not is_disabled <- !init_goal(followEnemy(Op)).

+!select_goal : not is_leave_goal & is_survey_goal & not is_disabled <- !init_goal(survey).
+!select_goal : pathTogoSwarm(_, _) & not is_at_swarm_position & pathTogoSwarm(_, []) <- !cancelSwarmTravel; !select_goal.
+!select_goal : not is_almost_full_map & pathTogoSwarm(_, _) & not is_at_swarm_position <- !init_goal(walkSwarm).

+!select_goal : not is_almost_full_map & is_leave_goal  <- !init_goal(random_walk).
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).

+!select_goal : not is_disabled & is_good_map_conquered  <-
    .print("Good map conquered!"); 
    !init_goal(actSwarm).
    
+!select_goal : not is_disabled & is_at_swarm_position_test & can_expand_to(V) <-
    .print("Stop! Stand still! I can expand to ", V); 
    !init_goal(goto(V)).

+!select_goal : not is_disabled & is_at_swarm_position_test  <-
    .print("Stop! Stand still!"); 
    !init_goal(actSwarm).
    
+!select_goal: noMoreVertexToProbe & not is_at_swarm_position & get_vertex_to_go_swarm(D, Path) <- !init_goal(gotoPathFastSwarm(Path)).

+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
    true
<-
    +maxStrengthSeen(1); 
    +maxHealthSeen(1);
    +timeBetweenInspect(30);
    +costInspect(2);
    
    +priorityEntity(inspector1, inspector2);
    +priorityEntity(inspector1, inspector3);
    +priorityEntity(inspector1, inspector4);
    
    +priorityEntity(inspector2, inspector3);
    +priorityEntity(inspector2, inspector4);
    
    +priorityEntity(inspector3, inspector4).

+!actSwarm:
    is_inspect_goal_swarm
<-
    !inspect.
    
+!actSwarm:
    true
<-
    !recharge.

+!inspect:  
    true
<- 
    .print("I am going to inspect an entity");
    !do(inspect).
    
+!followEnemy(Op): //I decide to recharge because I don't have enough energy 
    position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
    ia.edge(MyV,Op,W) & energy(MyE) & costInspect(CostInspect) & MyE < W + CostInspect
<- 
    .print("I have chose to inspect an enemy at ",Op, " but I don't have enough energy. I'm going to recharge firstly.I have ", MyE, " and I need ", W + CostInspect);
    !recharge.
    
+!followEnemy(Op):  
    position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam &
    ia.edge(MyV,Op,W) & energy(MyE) & costInspect(CostInspect) & MyE >= W + CostInspect
<- 
    .print("I have chose to inspect an enemy at ",Op, " and I have enough energy. I have ", MyE, " and I need ", W + CostInspect);
    !goto(Op).
    
+!followEnemy(Op): 
    true
<- 
    .print("I have chose to inspect an enemy at ",Op);
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
            
//Percepts
/* Percepts Entity */
@inspectedEntity1[atomic]
+inspectedEntity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange):
    step(S) & not myTeam(Team)
<-
    -evaluatedEntity(Entity, _, _, _, _, _, _, _, _, _);
    +evaluatedEntity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange);
    .abolish(lastInspectEntity(_, _));
    +lastInspectEntity(Entity, S);
    !broadcastInspect(Entity, Type);
    +entityType(Entity, Type);
    !evaluateHealth(MaxHealth, Type);
    !evaluateStrength(Strength, Type);
    !!broadcastInspectForInspectors(Entity, Type, S);
    !!broadcastInspectForSaboteursHealth(Entity, MaxHealth);
    !!broadcastInspectForSaboteursStrength(Entity, Strength);
    !!informCoach(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange, S);
    .print("The entity ", Entity, " was inspected Energy (", Energy, ",", MaxEnergy, ") Health (", Health, ",", MaxHealth, ") Strength ", Strength).

+!broadcastInspect(Entity, Type):
    not entityType(Entity, Type)
<-
    .print("Sending inspected entity in broadcast ", Entity, " ", Type);
    .broadcast(tell,entityType(Entity, Type)).
+!broadcastInspect(Entity, Type): true <- true.

+!broadcastInspectForSaboteursHealth(Entity, MaxHealth):
    true
<-
    .send(saboteur1, achieve, setEntityHealth(Entity, MaxHealth));
    .send(saboteur2, achieve, setEntityHealth(Entity, MaxHealth));
    .send(saboteur3, achieve, setEntityHealth(Entity, MaxHealth));
    .send(saboteur4, achieve, setEntityHealth(Entity, MaxHealth)).
    
+!broadcastInspectForSaboteursStrength(Entity, MaxStrength):
    true
<-
    .send(saboteur1, achieve, setEntityNewMaxStrength(Entity, MaxStrength));
    .send(saboteur2, achieve, setEntityNewMaxStrength(Entity, MaxStrength));
    .send(saboteur3, achieve, setEntityNewMaxStrength(Entity, MaxStrength));
    .send(saboteur4, achieve, setEntityNewMaxStrength(Entity, MaxStrength)).

+!broadcastInspectForInspectors(Entity, Type, S):
    .my_name(inspector1)
<-
    .send(inspector2, achieve, setNewEntityInspected(Entity, Type, S));
    .send(inspector3, achieve, setNewEntityInspected(Entity, Type, S));
    .send(inspector4, achieve, setNewEntityInspected(Entity, Type, S)).

+!broadcastInspectForInspectors(Entity, Type, S):
    .my_name(inspector2)
<-
    .send(inspector1, achieve, setNewEntityInspected(Entity, Type, S));
    .send(inspector3, achieve, setNewEntityInspected(Entity, Type, S));
    .send(inspector4, achieve, setNewEntityInspected(Entity, Type, S)).
    
+!broadcastInspectForInspectors(Entity, Type, S):
    .my_name(inspector3)
<-
    .send(inspector1, achieve, setNewEntityInspected(Entity, Type, S));
    .send(inspector2, achieve, setNewEntityInspected(Entity, Type, S));
    .send(inspector4, achieve, setNewEntityInspected(Entity, Type, S)).
    
+!broadcastInspectForInspectors(Entity, Type, S):
    .my_name(inspector4)
<-
    .send(inspector1, achieve, setNewEntityInspected(Entity, Type, S));
    .send(inspector2, achieve, setNewEntityInspected(Entity, Type, S));
    .send(inspector3, achieve, setNewEntityInspected(Entity, Type, S)).
    
+!setNewEntityInspected(Entity, Type, S):
    true
<-
    .abolish(lastInspectEntity(_, _));
    +lastInspectEntity(Entity, S).
    
+!evaluateHealth(Health, Type):
    maxHealthSeen(MaxH) & Health > MaxH & Type == "Saboteur"
<-
    -+maxHealthSeen(Health);
    .print("I saw a new max Health of a ", Type).
+!evaluateHealth(Health, Type): true <- true.
    
+!evaluateStrength(Strength, Type):
    maxStrengthSeen(MaxS) & Strength > MaxS & Type == "Saboteur"
<-
    -+maxStrengthSeen(Strength);
    .print("I saw a new max Strength of a ", Type).
+!evaluateStrength(Strength, Type): true <- true.
    
@do0[atomic]
+!do(Act): 
    step(S) & not stepDone(S)
<- 
    -+stepDone(S);
    Act;
    !!synchronizeGraph.

@do1[atomic]
+!do(Act): 
    step(S)
<- 
    .print("ERROR! I already performed an action for this step! ", S).

+!newPosition(V): 
    true 
<- 
    !newPositionRepairedGoal(V);
    !newPositionSwarmGoal(V);
    !!broadcastCurrentPosition(V).

+money(M):
    true
<-
    -+currentMoney(M).

@conceivePermissionToBuy1[atomic]
+!conceivePermissionToBuy[source(AgentName)]:
    currentMoney(M) & M > 2
<-
    -+currentMoney(M-2);
    .print(AgentName, " wants to buy something, I grant this permission...");
    .send(AgentName, tell, canBuy).

+!conceivePermissionToBuy[source(AgentName)]:
    true
<-
    .print(AgentName, " wants to buy something, I don't grant this permission...").
        
+!newStepPosAction(S):  true <- true.

+!processEntity(Entity): true <- true.

+!informCoach(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange, S):
    true
<-
    .send(coach, tell, entity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange, S)).

{ include("loadAgents.asl") }
