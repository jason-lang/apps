{ include("mod.common.asl") }

/*
 * Check if there is a friend at the same vertex and he is disabled
 */
is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, repairer, _) & 
                            not nextStepRepairer(_,Entity,S) &
                            not there_is_enemy_at(MyV).
 
is_repair_goal(Entity) :- position(MyV) & 
                            step(S) &
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, saboteur, _) & 
                            not nextStepRepairer(_,Entity,S).
                            
is_repair_goal(Entity) :- position(MyV) &
                            step(S) & S <= 200 &
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, explorer, _) & 
                            not nextStepRepairer(_,Entity,S).

is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, repairer, _) & 
                            not nextStepRepairer(_,Entity,S).

is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            not nextStepRepairer(_,Entity,S).
                            
                            
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & friend(_, Entity, repairer, _), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- position(MyV) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & friend(_, Entity, repairer, _), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                            
there_is_disabled_friend_nearby(Op) :- position(MyV) & step(S) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & not there_is_enemy_at(V) & not nextStepRepairer(_,V,S), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- position(MyV) & step(S) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & not there_is_enemy_at(V) & not nextStepRepairer(_,V,S), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- position(MyV) & step(S) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & not nextStepRepairer(_,V,S), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- position(MyV) & step(S) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & visibleEntity(Entity, V, MyTeam, disabled) & Entity \== MyName & not nextStepRepairer(_,V,S), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
best_proposal_repair(AgentName, Lenght) :- .setof(L, pathProposal(AgentName, _, _, L), Options) &
                                           .min(Options, Lenght).
                                           
get_vertex_to_go_repair_appointment(D, Path) :- position(MyV)  & .my_name(MyAgentName) & 
												busy(AgentName) & friend(AgentName, _, _, Id) &
												ia.getAgentPosition(Id, D) &
												ia.shortestPath(MyV, D, Path, Lenght) &
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
    step(S) & .count(nextStepRepairer(_, _, S), Number) &
	Number < NumberRequired &
	numberWaits(K)
<-  
    //.print("Waiting decision ", Number, "/", NumberRequired);
    .wait(50);
    -+numberWaits(K+1);
    !wait_and_select_goal.
+!wait_and_select_goal <- !select_goal.

+!select_goal: is_energy_goal 
		<- !init_goal(recharge).
+!select_goal : is_repair_goal(Entity) 
		<- !init_goal(repair(Entity)).
+!select_goal : is_wait_repair_goal(V) 
		<- .print("Waiting to be repaired. Recharging...");
    		!init_goal(recharge).
+!select_goal: there_is_disabled_friend_nearby(V) 
		<- !init_goal(goto(V)).
+!select_goal : is_parry_goal 
		<- !init_goal(parry).
		
+!select_goal: get_vertex_to_go_repair_appointment(D, Path) 
		<- 
			.print("I have an appointment with some agent to repair it. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).		
		
+!select_goal: is_survey_goal  
		<- !init_goal(survey).
+!select_goal: is_disabled & get_vertex_to_go_be_repaired_appointment(D, Path) 
		<- 
			.print("I have an appointment with some repairer. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
+!select_goal: is_disabled & get_vertex_to_go_repair(D, Path) 
		<- 
			.print("I'm forever alone. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).	
+!select_goal                  
		<- !init_goal(random_walk).
		
/*
 * These functions must be dependent of each kind of agent because they will
 * need to share some information with the other friends of the same kind
 */
+!do(Act): 
    step(S) & stepDone(S)
<- 
    .print("ERROR! I already performed an action for this step! ", S).

+!do(repair(Ag)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.send(SetAgents,tell,nextStepRepairer(MyName, Ag, S));
    !commitAction(repair(Ag));
    !!clearNextStepRepairer.
    
+!do(goto(V)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.send(SetAgents,tell,nextStepRepairer(MyName, V, S));
    !commitAction(goto(V));
    !!clearNextStepRepairer.

+!do(Act): 
    step(S) & position(V) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.send(SetAgents,tell,nextStepRepairer(MyName, V, S));
    !commitAction(Act);
    !!clearNextStepRepairer.

+!clearNextStepRepairer <-
	.abolish(nextStepRepairer(_, _, _)).
    
+!initSpecific.
+!processAfterStep(S).






+hit(AgentName, Pos)[source(self)]:
    infinite(INF) & .my_name(AgentName)
<-
    .print(AgentName, " (me) was hit at ", Pos);
    .abolish(hit(AgentName, _));
    .abolish(pathProposal(AgentName, _, _, _));
    .abolish(closest(_, AgentName, _));
    +closest(none, AgentName, INF);
    
    !searchRepairerToHelp(AgentName, Pos).
    
+hit(AgentName, Pos):
    infinite(INF)
<-
    .print(AgentName, " was hit at ", Pos);
    .abolish(hit(AgentName, _));
    .abolish(pathProposal(AgentName, _, _, _));
    .abolish(closest(_, AgentName, _));
    +closest(none, AgentName, INF);
    
    !searchRepairerToHelp(AgentName, Pos).
    
    
+!searchRepairerToHelp(AgentName, Pos):
    .findall(Agent, friend(Agent, _, repairer, _), SetAgents)
<-
    .send(SetAgents, achieve, canHelp(AgentName, Pos));
    
    .wait(400); //TODO talvez esperar todas as respostas
    
    !notifySelectedRepairer(AgentName).
    
@pathProposal[atomic]
+pathProposal(AgentName, Pos, Path, Lenght)[source(RepairerName)]:
	.my_name(MyName) & play(MyName,repairerLeader,"grMain")
<-
	!evaluateProposal(AgentName, Pos, Path, Lenght, RepairerName).

+!evaluateProposal(AgentName, Pos, Path, Lenght, self):
	closest(RepairerClosest, AgentName, Distance) & Lenght < Distance & .my_name(MyName)
<-
    -closest(_, AgentName, _);
    +closest(MyName, AgentName, Lenght);
    .print("Received a new best proposal from ", MyName, " with the path ", Path, " and distance ", Lenght, ". Better than ", Distance).
+!evaluateProposal(AgentName, Pos, Path, Lenght, RepairerName):
	closest(RepairerClosest, AgentName, Distance) & Lenght < Distance
<-
    -closest(_, AgentName, _);
    +closest(RepairerName, AgentName, Lenght);
    .print("Received a new best proposal from ", RepairerName, " with the path ", Path, " and distance ", Lenght, ". Better than ", Distance).	
+!evaluateProposal(AgentName, Pos, Path, Lenght, RepairerName): //TODO pode remover o corpo do plano
	closest(RepairerClosest, AgentName, Distance)
<-
	.print("Received a new proposal from ", RepairerName, " with the path ", Path, " and distance ", Lenght, ". It's not better than ", Distance).

@notifySelectedRepairer0[atomic]
+!notifySelectedRepairer(AgentName):
    .my_name(MyName) & play(MyName,repairerLeader,"grMain") &
    closest(MyName, AgentName, Distance) & repairerBusy(MyName, _) & Distance < INF
<-  
    .abolish(pathProposal(_, _, _, _)[source(self)]);
    .abolish(closest(_, AgentName, _));
    .print("### The best repairer ", MyName, " is already busy!");
    !selectNextBestRepairer(AgentName).

@notifySelectedRepairer1[atomic]
+!notifySelectedRepairer(AgentName):
    closest(RepairerName, AgentName, Distance) & repairerBusy(RepairerName, _) & Distance < INF
<-  
    .abolish(pathProposal(_, _, _, _)[source(RepairerName)]);
    .abolish(closest(_, AgentName, _));
    .print("### The best repairer ", RepairerName, " is already busy!");
    !selectNextBestRepairer(AgentName).

@notifySelectedRepairer2[atomic]
+!notifySelectedRepairer(AgentName):
    closest(Repairer, AgentName, Distance) & Repairer \== none & step(S)
<-
    +repairerBusy(Repairer, S);
    .send(Repairer, achieve, gotoCure(AgentName));
    
    !clearDataRepair(AgentName);
    
    .print("### Repairer ", Repairer, " is the closest to help ", AgentName, " at distance of ", Distance). //TODO avisa reparador
    
@notifySelectedRepairer3[atomic]
+!notifySelectedRepairer(AgentName):
    true
<-
    !clearDataRepair(AgentName);
    
    .print("### Nobody of repairers available to help ", AgentName).
    
    
+!selectNextBestRepairer(AgentName):
	.my_name(MyName) & play(MyName,repairerLeader,"grMain") &
    best_proposal_repair(AgentName, Lenght) & pathProposal(AgentName, _, _, Lenght)[source(self)] & Lenght < INF
<-
    +closest(MyName, AgentName, Lenght);
    .print("Looking for the next best repairer to help ", AgentName, ", found repairer1");
    !notifySelectedRepairer(AgentName).
    
+!selectNextBestRepairer(AgentName):
    best_proposal_repair(AgentName, Lenght) & pathProposal(AgentName, _, _, Lenght)[source(RepairerName)] & Lenght < INF
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
    .findall(Agent, friend(Agent, _, repairer, _), SetAgents)
<-
    .send(SetAgents, achieve, resetPathProposal(AgentName));
    .abolish(closest(_, AgentName, _)).

+iAmFree[source(RepairerName)] <-
	.abolish(iAmFree[source(RepairerName)]);
	.abolish(repairerBusy(RepairerName, _)).

/* Answer to the leader */
    
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
    not busy(_) & position(MyPos)
<-
    .print("Agent ", AgentName, " needs help. I can go. ", MyPos , " -> ", Pos);
    !calculePath(AgentName, MyPos, Pos).

+!canHelp(AgentName, Pos):
    infinite(INF)
<-
    +pathProposal(AgentName, Pos, none, INF);
    .print("Agent ", AgentName, " needs help. I cannot go.").
    
+!calculePath(AgentName, S, D):
    .my_name(MyName) & play(MyName,repairerLeader,"grMain")
<-
    .print("Calculating the shortest path...");
    ia.shortestPath(S, D, Path, Lenght);
    +pathProposal(AgentName, D, Path, Lenght).
    
+!calculePath(AgentName, S, D):
    play(RepairerLeader,repairerLeader,"grMain")
<-
    .print("Calculating the shortest path...");
    ia.shortestPath(S, D, Path, Lenght);
    +pathProposal(AgentName, D, Path, Lenght);
    .send(RepairerLeader, tell, pathProposal(AgentName, D, Path, Lenght));
    .print("Path to help ", AgentName, " at ", D, " from ", S, " is ", Path).
    
-!calculePath(AgentName, S, D):
    infinite(INF)
<- 
    +pathProposal(AgentName, D, none, INF);
    .print("I do not know any way to go from ", S, " to ", D).
    
+!resetPathProposal(AgentName):
    true
<-
    .abolish(pathProposal(AgentName,_,_,_)).
    
    
@gotoCure1[atomic]
+!gotoCure(AgentName):
    position(S) & pathProposal(AgentName, D, _, _) & not busy(_)
<-
    +busy(AgentName);
    .send(AgentName, tell, acceptedAppointment);
    .print("Going to cure ", AgentName).

+!gotoCure(AgentName):
    busy(_)
<-
    .print("I'm already busy with ", AgentName).
    
+iWasRepaired[source(AgentName)]: 
	play(RepairerLeader,repairerLeader,"grMain") 
<-
	.send(AgentName, tell, iAmFree);
	.abolish(iWasRepaired(_));
	.abolish(busy(_)).
