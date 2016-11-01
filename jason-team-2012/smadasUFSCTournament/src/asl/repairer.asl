//agent repairer
{ include("commonRules.asl") }
{ include("commonRules_notExplorer.asl") }
{ include("commonRules_parryRule.asl") }

/*
 * I have the buy goal when:
 * my health is less than the strength of some enemy saboteur
 * I have enough money
 */
is_buy_goal    :- myMaxHealth(MyH) & healthRequired(Hr) & MyH < Hr
                  & money(MyM) & MyM > 2.

//I'm going to cure someone
is_route_goal  :- busy & goingToCure(_, [_|T]) & not .empty(T).

/*
 * Check if there is a friend at the same vertex and he is disabled
 */
is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, repairer) & 
                            not nextStepRepairer(_,Entity,S) &
                            not there_is_enemy_at(MyV).
 
is_repair_goal(Entity) :- position(MyV) & 
                            step(S) &
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, saboteur) & 
                            not nextStepRepairer(_,Entity,S).
                            
is_repair_goal(Entity) :- position(MyV) &
                            step(S) & S <= 200 &
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, explorer) & 
                            not nextStepRepairer(_,Entity,S).

is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, repairer) & 
                            not nextStepRepairer(_,Entity,S).
                            
is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, explorer) & 
                            not nextStepRepairer(_,Entity,S).

is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, inspector) & 
                            not nextStepRepairer(_,Entity,S).

is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            not nextStepRepairer(_,Entity,S).
                            
there_is_more_repairers(RepairerNameFriend) :- position(MyV) & step(S) & myTeam(MyTeam) & myNameInContest(MyName) & .my_name(MyNameJason) & 
                            visibleEntity(Entity, MyV, MyTeam, _) & 
                            Entity \== MyName &
                            friend(RepairerNameFriend, Entity, repairer) & 
                            visibleEntity(EntityTwo, MyV, MyTeam, disabled) &
                            EntityTwo \== MyName & EntityTwo \== Entity &
                            priorityEntity(RepairerNameFriend, MyNameJason) &
                            not nextStepRepairer(RepairerNameFriend, _, S).
                            
/*
 * Check if there is a friend at some adjacent vertex and he is disabled
 */
there_is_disabled_repairer_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & friend(_, Entity, repairer), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
there_is_disabled_repairer_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & friend(_, Entity, repairer), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & not there_is_enemy_at(V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & not there_is_enemy_at(V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

//If I'm disabled and there is a normal repairer at some adjacent vertex, so I'm going to wait 
is_wait_repair_goal(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & 
                        ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, normal) & friend(_, Entity, repairer).
//If I'm disabled and there is a normal or disabled repairer at the same vertex, so I'm going to wait
is_wait_repair_goal(MyV) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &  
                        visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer) & Entity \== MyName.
//If I'm disabled and there is a disabled repairer at some adjacent vertex, so I'm going to wait if my friend has higher priority
is_wait_repair_goal(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & .my_name(MyAgentName) & 
                        ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(AgentName, Entity, repairer) & priorityEntity(AgentName, MyAgentName) & MyAgentName \== AgentName.
                    
best_proposal_repair(AgentName, Lenght) :- .setof(L, pathProposal(AgentName, _, _, L), Options) &
                                           .min(Options, Lenght).
                                           
noMoreVertexToProbe :- true.

/* The sequence of the priority plans */
+!select_goal:
    there_is_more_repairers(RepairerNameFriend) & not numberWaits(_)
<-
    +numberWaits(0);
    !select_goal.
    
+!select_goal:
    (there_is_more_repairers(RepairerNameFriend) & numberWaits(K) & K >= 6) | (step(0) & not nextStepRepairerAll(10))
<-
    .print("I can't wait anymore!");
    -+numberWaits(0);
    -+nextStepRepairerAll(10);
    !select_goal.

+!select_goal:
    there_is_more_repairers(RepairerNameFriend) & numberWaits(K)
<-  
    .print("Waiting decision ", RepairerNameFriend);
    .wait(150);
    -+numberWaits(K+1);
    !select_goal.   


+!select_goal : is_heartbeat_goal
    <-
    .print("I'm in the same place yet!!!!!!");
    .abolish(stepsSamePosition(_, _));
    !select_goal.

+!select_goal : is_energy_goal <- !init_goal(recharge).
+!select_goal : is_repair_goal(Entity) <- !init_goal(repair(Entity)).

+!select_goal : there_is_disabled_repairer_friend_nearby(Op) <- !init_goal(followFriend(Op)).
+!select_goal : there_is_disabled_friend_nearby(Op) & there_is_enemy_at(Op) <-
    .print("There is a disable friend at ", Op, " but there is an enemy there!"); 
    !init_goal(recharge). //Wait the friend
+!select_goal : there_is_disabled_friend_nearby(Op) <- !init_goal(followFriend(Op)).


+!select_goal : is_wait_repair_goal(_) <-
    .print("Waiting to be repaired."); 
    !init_goal(recharge). //Instead of don't do anything, then recharge
        
+!select_goal : is_route_repaired_goal <- !reviewMyPositionRepaired; !init_goal(repair_walk). //I'm going to be repaired by some agent

+!select_goal : waitABit <- 
    .print("I'm waiting a bit because the repairers are choosing my helper, so recharge!");
    !init_goal(recharge).
    
+!select_goal : is_disabled <- !init_goal(walk_repair_forever_alone).
    
+!select_goal : not is_almost_full_map & is_route_goal <- !init_goal(random_walk). //I'm going to cure some agent
+!select_goal : is_parry_goal & not is_disabled <- !init_goal(parry).
+!select_goal : is_leave_goal & not is_disabled & not is_almost_full_map <- !init_goal(random_walk).
+!select_goal : is_leave_goal & not is_disabled & is_almost_full_map <- !init_goal(parry).
+!select_goal : is_survey_goal & not is_disabled <- !init_goal(survey).

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

+!select_goal                  <- !init_goal(random_walk).
-!select_goal[error_msg(M)]    <- .print("Error ",M).

/* Plans */
{ include("commonPlans.asl") }

//Initialize every belief here
+!init: 
    true
<-
    +priorityEntity(repairer1, repairer2);
    +priorityEntity(repairer1, repairer3);
    +priorityEntity(repairer1, repairer4);
    
    +priorityEntity(repairer2, repairer3);
    +priorityEntity(repairer2, repairer4);
    
    +priorityEntity(repairer3, repairer4);
    +healthRequired(4); //one more than max strength of enemy saboteur
    .print("Initialized!"). 
    
+!buy: 
    money(M) & health(MyH) & healthRequired(Hr) & MyH < Hr
<- 
    .abolish(canBuy);
    .print("I am going to buy shield! My money is ",M, " and I need ", Hr, " of health");
    !do(buy(shield)).
    
+!repair(Entity):  
    goingToCure(Entity, _)
<- 
    .print("I am going to repair an entity and its name is ", Entity);
    !do(repair(Entity));
    !notifyRepairerFree.
    
+!repair(Entity):  
    true
<- 
    .print("I am going to repair an entity and its name is ", Entity);
    !do(repair(Entity)).    

+!followFriend(Op): 
    goingToCure(AgentName, _) & myTeam(MyTeam) & myNameInContest(MyName) & 
    visibleEntity(Entity, Op, MyTeam, disabled) & Entity \== MyName & friend(AgentName, Entity, _)
<- 
    .print("I have chose to repair a friend that I have an appointment at ",Op);
    !testIHaveAppointment;
    !goto(Op).
    
+!followFriend(Op): 
    goingToCure(AgentName, _)
<-
    .send(AgentName, achieve, cancelAppointment);
    .print("I have chose to repair other friend at ",Op);
    !notifyRepairerFree;
    !testIHaveAppointment;
    !goto(Op).  
    
+!followFriend(Op): 
    true
<- 
    .print("I have chose to repair a friend at ",Op);
    !testIHaveAppointment;
    !goto(Op).
    
+!testIHaveAppointment:
    gotoVertexRepair(_,RepairerName,_)
<-
    .send(RepairerName, achieve, notifyRepairerFree);
    -gotoVertexRepair(_,_,_);
    .print("I'm going to repair other friend or be repaired and cancel my appointment with ", RepairerName).
    
+!testIHaveAppointment: true <- true.

+!walkRepairByRepairer(Op): 
    true
<- 
    .print("I have chose to be repaired at ",Op);
    !testIHaveAppointment;
    !goto(Op).

+!random_walk: 
    goingToCure(AgentName, [H|T]) & position(H)
<- 
    -goingToCure(_, _);
    +goingToCure(AgentName, T);
    !random_walk.
    
+!random_walk: 
    goingToCure(AgentName, [H|T]) & position(MyV) & ia.edge(MyV,H,_)
<- 
    .print("I'm going to cure the agent ", AgentName, " at ",H);
    !goto(H).
    
+!random_walk: 
    goingToCure(AgentName, [H|T]) & position(MyV) & not ia.edge(MyV,H,_)
<- 
    .print("Ops! Wrong way to ",H, ". I'm going to select other goal to do.");
    .send(AgentName, achieve, cancelAppointment);
    !notifyRepairerFree;
    !testIHaveAppointment;
    !select_goal.
    
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
    
+!parry:  
    true
<- 
    .print("I am going to parry because there's a saboteur here");
    !do(parry).
            
//Percepts  
+!clearDecision:
    true
 <-
    .abolish(nextStepRepairerCounted(_));
    .abolish(nextStepRepairer(_, _, _));
    .abolish(nextStepRepairerAll(_));
    .abolish(numberWaits(_));
    +nextStepRepairerAll(0);
    +numberWaits(0).
    
@nextStepRepairer1[atomic]  
 +nextStepRepairer(Ex, _, _):
    not nextStepRepairerCounted(Ex) & nextStepRepairerAll(X)
 <-
    +nextStepRepairerCounted(Ex);
    -+nextStepRepairerAll(X+1).
    
@nextStepRepairer2[atomic]  
 +nextStepRepairer(Ex, _, _):
    not nextStepRepairerCounted(Ex) & not nextStepRepairerAll(_)
 <-
    +nextStepRepairerCounted(Ex);
    +nextStepRepairerAll(1).
    
@do0[atomic]
+!do(Act): 
    step(S) & stepDone(S)
<-
    !clearDecision; 
    .print("ERROR! I already performed an action for this step! ", S).
    
 // the following plans are used to send only one action each cycle
@do1[atomic]
+!do(repair(V)): 
    step(S) & .my_name(repairer1)
<- 
    !clearDecision;
    .send(repairer2,tell,nextStepRepairer(repairer1, V, S));
    .send(repairer3,tell,nextStepRepairer(repairer1, V, S));
    .send(repairer4,tell,nextStepRepairer(repairer1, V, S));
    -+stepDone(S);
    repair(V);
    !!synchronizeGraph.

@do2[atomic]
+!do(repair(V)): 
    step(S) & .my_name(repairer2)
<-
    !clearDecision; 
    .send(repairer3,tell,nextStepRepairer(repairer2, V, S));
    .send(repairer4,tell,nextStepRepairer(repairer2, V, S));
    -+stepDone(S);
    repair(V);
    !!synchronizeGraph.

@do3[atomic]
+!do(repair(V)): 
    step(S) & .my_name(repairer3)
<-
    !clearDecision; 
    .send(repairer4,tell,nextStepRepairer(repairer3, V, S));
    -+stepDone(S);
    repair(V);
    !!synchronizeGraph.

@do4[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(repairer1) 
<-
    !clearDecision;
    .send(repairer2,tell,nextStepRepairer(repairer1, repairer1Skip, S));
    .send(repairer3,tell,nextStepRepairer(repairer1, repairer1Skip, S));
    .send(repairer4,tell,nextStepRepairer(repairer1, repairer1Skip, S));
    .print("I'm repairer1, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !!synchronizeGraph.
    
@do5[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(repairer2) 
<-
    !clearDecision;
    .send(repairer3,tell,nextStepRepairer(repairer2, repairer2Skip, S));
    .send(repairer4,tell,nextStepRepairer(repairer2, repairer2Skip, S));
    .print("I'm repairer2, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !!synchronizeGraph.

@do6[atomic]
+!do(Act): 
    step(S) & position(V) & .my_name(repairer3) 
<-
    !clearDecision;
    .send(repairer4,tell,nextStepRepairer(repairer3, repairer3Skip, S)); 
    .print("I'm repairer3, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !!synchronizeGraph.
    
@do7[atomic]
+!do(Act): 
    step(S)
<-
    !clearDecision; 
    .print("I'm repairer4, and I'm notifying my friends.");
    -+stepDone(S);
    Act;
    !!synchronizeGraph.
    
    
+hit(AgentName, Pos)[source(self)]: true <- true.
+hit(AgentName, Pos):
    infinite(INF)
<-
    .print(AgentName, " was hit at ", Pos);
    .abolish(hit(AgentName, _));
    .abolish(pathProposal(AgentName, _, _, _));
    .abolish(closest(_, AgentName, _));
    +closest(none, AgentName, INF);
    +hit(AgentName, Pos);
    
    !searchRepairerToHelp(AgentName, Pos).
    
+!searchRepairerToHelp(repairer1, Pos):
    true
<-
    +waitABit;
    .send(repairer2, achieve, canHelp(repairer1, Pos));
    .send(repairer3, achieve, canHelp(repairer1, Pos));
    .send(repairer4, achieve, canHelp(repairer1, Pos));

    !canHelp(repairer1, Pos);
    
    .wait(400);
    
    !notifySelectedRepairer(repairer1);
    -waitABit.
    
+!searchRepairerToHelp(AgentName, Pos):
    true
<-
    .send(AgentName, tell, waitABit);
    .send(repairer2, achieve, canHelp(AgentName, Pos));
    .send(repairer3, achieve, canHelp(AgentName, Pos));
    .send(repairer4, achieve, canHelp(AgentName, Pos));

    !canHelp(AgentName, Pos);
    
    .wait(400);
    
    !notifySelectedRepairer(AgentName);
    .send(AgentName, untell, waitABit).
    
+?pathProposal(AgentName, Pos, Path, Lenght):
    not pathProposal(AgentName, Pos, _, _)
<-
    !canHelp(AgentName, Pos);
    ?pathProposal(AgentName, Pos, Path, Lenght).
    
@pathProposal0[atomic]
+pathProposal(AgentName, Pos, Path, Lenght)[source(self)]:
    closest(RepairerClosest, AgentName, Distance) & Lenght < Distance
<-
    -closest(_, AgentName, _);
    +closest(repairer1, AgentName, Lenght);
    .print("Received a new best proposal from repairer1 with the path ", Path, " and distance ", Lenght, ". Better than ", Distance).

@pathProposal1[atomic]
+pathProposal(AgentName, Pos, Path, Lenght)[source(RepairerName)]:
    closest(RepairerClosest, AgentName, Distance) & Lenght < Distance
<-
    -closest(_, AgentName, _);
    +closest(RepairerName, AgentName, Lenght);
    .print("Received a new best proposal from ", RepairerName, " with the path ", Path, " and distance ", Lenght, ". Better than ", Distance).

+!selectNextBestRepairer(AgentName):
    best_proposal_repair(Lenght) & pathProposal(AgentName, _, _, Lenght)[source(self)] & Lenght < INF
<-
    +closest(repairer1, AgentName, Lenght);
    .print("Looking for the next best repairer to help ", AgentName, ", found repairer1");
    !notifySelectedRepairer(AgentName).
    
+!selectNextBestRepairer(AgentName):
    best_proposal_repair(Lenght) & pathProposal(AgentName, _, _, Lenght)[source(RepairerName)] & Lenght < INF
<-
    +closest(RepairerName, AgentName, Lenght);
    .print("Looking for the next best repairer to help ", AgentName, ", found ", RepairerName);
    !notifySelectedRepairer(AgentName).

+!selectNextBestRepairer(AgentName):
    true
<-
    !clearDataRepair(AgentName);
    .print("Looking for the next best repairer to help ", AgentName, ", nobody found!!!!"). //TODO guardar numa lista o agente

+!clearDataRepair(AgentName):
    true
<-
    .send(repairer2, achieve, resetPathProposal(AgentName));
    .send(repairer3, achieve, resetPathProposal(AgentName));
    .send(repairer4, achieve, resetPathProposal(AgentName));
    .abolish(pathProposal(AgentName, _, _, _));
    .abolish(closest(_, AgentName, _));
    .abolish(hit(AgentName, _));
    -waitingDecisionProposal(AgentName).

@notifySelectedRepairer0[atomic]
+!notifySelectedRepairer(AgentName):
    closest(repairer1, AgentRepaired, Distance) & repairerBusy(repairer1, _) & Distance < INF
<-  
    .abolish(pathProposal(_, _, _, _)[source(self)]);
    .abolish(closest(_, AgentName, _));
    .print("### The best repairer repairer1 is already busy!");
    !selectNextBestRepairer(AgentName).

@notifySelectedRepairer1[atomic]
+!notifySelectedRepairer(AgentName):
    closest(RepairerName, AgentRepaired, Distance) & repairerBusy(RepairerName, _) & Distance < INF
<-  
    .abolish(pathProposal(_, _, _, _)[source(RepairerName)]);
    .abolish(closest(_, AgentName, _));
    .print("### The best repairer ", RepairerName, " is already busy!");
    !selectNextBestRepairer(AgentName).
    
@notifySelectedRepairer2[atomic]
+!notifySelectedRepairer(AgentName):
    closest(repairer1, AgentName, Distance) & step(S)
<-
    +repairerBusy(repairer1, S);    
    !gotoCure(AgentName);
    !clearDataRepair(AgentName);
    
    .print("### Repairer repairer1 (me) is the closest to help ", AgentName, " at distance of ", Distance). //TODO avisa reparador

@notifySelectedRepairer3[atomic]
+!notifySelectedRepairer(AgentName):
    closest(Repairer, AgentName, Distance) & Repairer \== none & step(S)
<-
    +repairerBusy(Repairer, S);
    .send(Repairer, achieve, gotoCure(AgentName));
    
    !clearDataRepair(AgentName);
    
    .print("### Repairer ", Repairer, " is the closest to help ", AgentName, " at distance of ", Distance). //TODO avisa reparador
    
@notifySelectedRepairer4[atomic]
+!notifySelectedRepairer(AgentName):
    true
<-
    !clearDataRepair(AgentName);
    
    .print("### Nobody of repairers available to help ", AgentName). //TODO avisa reparador

+!resetPathProposal(AgentName):
    true
<-
    -waitingDecisionProposal(AgentName);
    .abolish(pathProposal(AgentName,_,_,_)).

+iWasRepaired[source(self)]:
    true
<-
    .print("Agent repairer1 was repaired").
    
+iWasRepaired[source(AgentName)]:
    true
<-
    .print("Agent ", AgentName, " was repaired").
    
+!repairerFree(RepairerName):
    true
<-
    .abolish(repairerBusy(RepairerName, _)).


+!canHelp(AgentName, Pos):
    is_disabled & infinite(INF)
<-
    +pathProposal(AgentName, Pos, none, INF);
    .print("Agent ", AgentName, " needs help. I cannot go. I'm disabled."). 
    
+!canHelp(AgentName, Pos):
    .my_name(AgentName)
<-
    +pathProposal(AgentName, Pos, none, INF);
    .print("Agent ", AgentName, " needs help. I cannot repair myself.").
    
+!canHelp(AgentName, Pos):
    not busy & currentPosition(MyPos) & not gotoVertexRepair(_,_,_)
<-
    !notifyRepairerFree;
    -tryingGetPosition;
    +waitingDecisionProposal(AgentName);
    .print("Agent ", AgentName, " needs help. I can go. ", MyPos , " -> ", Pos);
    !calculePath(AgentName, MyPos, Pos).
    
+!canHelp(AgentName, Pos):
    not currentPosition(MyPos)
<-
    !notifyRepairerFree;
    +tryingGetPosition;
    .print("Agent ", AgentName, " needs help. I can go. ", MyPos , " -> ", Pos, ". Waiting a bit... ");
    .wait(50);
    !canHelp(AgentName, Pos).
    
+!canHelp(AgentName, Pos):
    not currentPosition(MyPos) & tryingGetPosition
<-
    -tryingGetPosition;
    +pathProposal(AgentName, Pos, none, INF);
    .print("Agent ", AgentName, " needs help. I cannot go.").

+!canHelp(AgentName, Pos):
    infinite(INF)
<-
    +pathProposal(AgentName, Pos, none, INF);
    .print("Agent ", AgentName, " needs help. I cannot go.").
    
+!calculePath(AgentName, S, D):
    .my_name(repairer1)
<-
    .print("Calculating the shortest path...");
    ia.shortestPath(S, D, Path, Lenght);
    +pathProposal(AgentName, D, Path, Lenght).
    
+!calculePath(AgentName, S, D):
    true
<-
    .print("Calculating the shortest path...");
    ia.shortestPath(S, D, Path, Lenght);
    +pathProposal(AgentName, D, Path, Lenght);
    .send(repairer1, tell, pathProposal(AgentName, D, Path, Lenght));
    .print("Path to help ", AgentName, " at ", D, " from ", S, " is ", Path).
    
-!calculePath(AgentName, S, D):
    infinite(INF)
<- 
    +pathProposal(AgentName, D, none, INF);
    .print("I do not know any way to go from ", S, " to ", D).

@gotoCure1[atomic]
+!gotoCure(AgentName):
    position(S) & pathProposal(AgentName, D, _, _) & not busy
<-
    +busy;
    ia.shortestPath(S, D, Path, Lenght);
    .print("Calculating again the path to help ", AgentName, " between ", S, " and ", D, " -> ", Path);
    .abolish(pathProposal(AgentName, _, _, _));
    +pathProposal(AgentName, D, Path, Lenght);
    +goingToCure(AgentName, Path);
    .reverse(Path, ReversePath);
    .send(AgentName, achieve, gotoRepaired(D, ReversePath));
    .print("Going to cure ", AgentName, ": ", Path, " Lenght: ", Lenght).

+!gotoCure(AgentName):
    busy & goingToCure(AgentName, Path)
<-
    .print("I'm already busy with ", AgentName).

+!gotoCure(AgentName):
    not position(_) & not tries(_)
<-
    +tries(1);
    .print("Wait for position...");
    .wait( { +position(_) }, 100, _);
    !gotoCure(AgentName).
    
+!gotoCure(AgentName):
    not position(_) & tries(T) & T < 5
<-
    -+tries(T+1);
    .print("Wait for position... ", T);
    .wait( { +position(_) }, 100, _);
    !gotoCure(AgentName).
    
+!gotoCure(AgentName):
    tries(_)
<-
    .abolish(tries(_));
    .print("Wait for position failed... I cannot wait!");
    !notifyRepairerFree;
    !testIHaveAppointment.
    
+!gotoCure(AgentName):
    true
<-
    .abolish(tries(_));
    .print("Wait for position failed... I cannot wait, nothing to do!");
    !notifyRepairerFree;
    !testIHaveAppointment.

+!notifyRepairerFree:
    .my_name(repairer1)
<-
    .abolish(goingToCure(_, _));
    -busy;
    .abolish(repairerBusy(repairer1, _)).
    
+!notifyRepairerFree:
    .my_name(RepairerName)
<-
    .abolish(goingToCure(_, _));
    -busy;
    .send(repairer1, achieve, repairerFree(RepairerName)).
+!notifyRepairerFree: true <- true.

+!newPosition(V):
    true
<-
    !newPositionRepairGoal(V);
    !newPositionRepairedGoal(V);
    !newPositionSwarmGoal(V);
    !!broadcastCurrentPosition(V).

+!newPositionRepairGoal(V): 
    goingToCure(AgentName, [V|[]])
<- 
    !notifyRepairerFree;
    .print("I arrived at ", V).
    
+!newPositionRepairGoal(V): 
    goingToCure(AgentName, [V|T])
<- 
    -goingToCure(_, _);
    +goingToCure(AgentName, T);
    .print("I'm at ", V, ". My travel is: ", T).
    
+!newPositionRepairGoal(V): true <- true.
+!newStepPosAction(S):  true <- true.
    
+!processEntity(Entity): true <- true.

{ include("loadAgents.asl") }
