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
                            not nextStepRepairer(_,Entity,S).
                            
// MODIFICACOES  
                         
is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            .random(M) &
                            M > 0.80 &
                            ia.edge(MyV,V,_) &
                            visibleEntity(Entity, V, MyTeam, disabled) & 
                            Entity \== MyName &
                            friend(_, Entity, repairer, _) & 
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
                            friend(_, Entity, saboteur, _) & 
                            not nextStepRepairer(_,Entity,S).

is_repair_goal(Entity) :- position(MyV) &
                            step(S) & 
                            myTeam(MyTeam) & 
                            myNameInContest(MyName) & 
                            visibleEntity(Entity, MyV, MyTeam, disabled) & 
                            Entity \== MyName &
                            not nextStepRepairer(_,Entity,S).
                            
                            
there_is_disabled_friend_nearby(Op) :- step(S) & position(MyV) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) &
                           		W \== INF & 
                           		visibleEntity(Entity, V, MyTeam, disabled) & 
                           		Entity \== MyName & 
                           		friend(_, Entity, repairer, _) &
                           		not nextStepRepairer(_,Entity,S) & not nextStepRepairer(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- step(S) & position(MyV) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		visibleEntity(Entity, V, MyTeam, disabled) & 
                           		Entity \== MyName & 
                           		friend(_, Entity, repairer, _) &
                           		not nextStepRepairer(_,Entity,S) & not nextStepRepairer(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                            
there_is_disabled_friend_nearby(Op) :- step(S) & position(MyV) & step(S) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		visibleEntity(Entity, V, MyTeam, disabled) & 
                           		Entity \== MyName & 
                           		not there_is_enemy_at(V) & 
                           		not nextStepRepairer(_,Entity,S) & not nextStepRepairer(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- step(S) & position(MyV) & step(S) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		visibleEntity(Entity, V, MyTeam, disabled) & 
                           		Entity \== MyName & 
                           		not there_is_enemy_at(V) & 
                           		not nextStepRepairer(_,Entity,S) & not nextStepRepairer(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- step(S) & position(MyV) & step(S) & myTeam(MyTeam) & maxWeight(INF) & myNameInContest(MyName) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & W \== INF & 
                           		visibleEntity(Entity, V, MyTeam, disabled) & 
                           		Entity \== MyName & 
                           		not nextStepRepairer(_,Entity,S) & not nextStepRepairer(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
there_is_disabled_friend_nearby(Op) :- step(S) & position(MyV) & step(S) & myTeam(MyTeam) & infinite(INF) & myNameInContest(MyName) &
                           .setof(V, 
                           		ia.edge(MyV,V,W) & 
                           		W \== INF & 
                           		visibleEntity(Entity, V, MyTeam, disabled) & 
                           		Entity \== MyName & 
                           		not nextStepRepairer(_,Entity,S) & not nextStepRepairer(_,V,S), Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
there_is_disabled_friend_nearby_wait(Entity) :- step(S) & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
                           					ia.edge(MyV,V,_) & 
                           					visibleEntity(Entity, V, MyTeam, disabled) & 
                           					Entity \== MyName.
                           
best_proposal_repair(AgentName, Lenght) :- .setof(L, pathProposal(AgentName, _, _, L), Options) &
                                           .min(Options, Lenght).
                                           
get_vertex_to_go_repair_appointment(D, Path) :- position(MyV)  & .my_name(MyAgentName) & 
												busy(AgentName) & friend(AgentName, _, _, Id) &
												ia.getAgentPosition(Id, D) &
												ia.shortestPath(MyV, D, Path, Lenght) &
                                            	Lenght > 2.
                                            	
is_goal_wait_good_zone_disabled_friend :- is_good_zone_repairer(_) & there_is_disabled_friend_nearby_wait(_).
is_good_zone_repairer(ZoneScore) :- zoneScore(ZoneScore) & goodZone(GoodZone) & ZoneScore >= GoodZone & not is_disabled.

+!wait_and_select_goal:
    not numberWaits(_)
<-
    +numberWaits(0);
    !wait_and_select_goal.
    
+!wait_and_select_goal:
    (numberWaits(K) & K >= 15) | step(0)
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
+!select_goal : not canCome(ComeT) & is_wait_repair_goal_nearby(V, Repairer)
		<- .print("Waiting to be repaired (nearby). ", V , " ", Repairer, ". Recharging..."); 
    		!init_goal(recharge).
+!select_goal : is_goto_repair_goal_nearby(V) 
		<- .print("Goto to be repaired (nearby)..."); 
    		!init_goal(goto(V)).
    		
+!select_goal: not is_good_zone_repairer(_) & there_is_disabled_friend_nearby(V) & zoneScore(ZoneScore)
		<-
		.print("Goto to repair some agent (nearby)... Zone: ", ZoneScore);  
		!init_goal(goto(V)).
+!select_goal : is_parry_goal 
		<- !init_goal(parry).
		
+!select_goal: get_vertex_to_go_repair_appointment(D, Path) & not is_goal_wait_good_zone_disabled_friend
		<- 
			.print("I have an appointment with some agent to repair it. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).		
		
+!select_goal: is_survey_goal  
		<- !init_goal(survey).
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
			
			
+!select_goal : is_good_map_conquered <-
    .print("Good map conquered! Stopped!"); 
    !init_goal(recharge).
    
/* Protect Island */
+!select_goal: is_keep_goal_island_enemy(Entity) <-
	.print("I'm at the island and I'm going to stay here ", Entity); 
	!init_goal(recharge).
+!select_goal: there_is_enemy_nearby_island_geral(Op) <-
	.print("I'm at the island and I'm going to ", Op, " to find some enemy inside"); 
	!init_goal(goto(Op)).
+!select_goal: get_vertex_to_go_attack_search_island_geral(D, Path) <-
	.print("I'm at the island and I'm going to ", D, " using ", Path, " to find some enemy there"); 
	!init_goal(gotoPath(Path)).
/* End Protect Island */
			
			
+!select_goal : going_to_outside_goal(V) & not is_goal_wait_good_zone_disabled_friend <-
    .print("I'm inside a region. I can expand to ", V); 
    !init_goal(goto(V)).
			
+!select_goal : can_expand_to(V) & not is_goal_wait_good_zone_disabled_friend <-
    .print("I can expand to ", V); 
    !init_goal(goto(V)).
			
+!select_goal: is_goal_keep_aim_vertex
		<- 
			.print("I'm at a pivot vertex. Recharging...");
			!init_goal(recharge).
			
+!select_goal: is_goal_aim_vertex(Op) & not is_goal_wait_good_zone_disabled_friend 
		<- 
			.print("I have a pivot vertex to go. I'm going to ", Op);
			!init_goal(goto(Op)).
+!select_goal: is_goal_aim_vertex(D, Path) & not is_goal_wait_good_zone_disabled_friend
		<- 
			.print("I have a pivot vertex to go. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).			

+!select_goal: is_goal_wait_good_zone_disabled_friend & zoneScore(ZoneScore)
		<- 
			.print("Waiting a friend because I'm in a good zone ", ZoneScore, ". Recharging...");
			!init_goal(recharge).
			
//Hills
+!select_goal : can_expand_to_hill(V) <-
    .print("I'm at a hill and I can expand to ", V); 
    !init_goal(goto(V)).
    
+!select_goal : is_at_aim_position_hill <-
    .print("Stop! Stand still! I'm settled at the hill!"); 
    !init_goal(recharge).
    
+!select_goal: is_goal_hill_vertex(Op) 
		<- 
			.print("I have a hill vertex to go. I'm going to ", Op);
			!init_goal(goto(Op)).
+!select_goal: is_goal_hill_vertex(D, Path) 
		<- 
			.print("I have a hill vertex to go. I'm going to ", D, " using path: ", Path);
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
    
+!do(Act): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents) &
    is_disabled
<- 
	.print("Sending action to ", S, " ", SetAgents);
	.send(SetAgents,tell,nextStepRepairer(MyName, none, S));
    !commitAction(Act);
    !!clearNextStepRepairer.

+!do(repair(Ag)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.print("Sending action to ", S, " ", SetAgents);
	.send(SetAgents,tell,nextStepRepairer(MyName, Ag, S));
    !commitAction(repair(Ag));
    !!clearNextStepRepairer.
    
+!do(goto(V)): 
    step(S) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.print("Sending action to ", S, " ", SetAgents);
	.send(SetAgents,tell,nextStepRepairer(MyName, V, S));
    !commitAction(goto(V));
    !!clearNextStepRepairer.

+!do(Act): 
    step(S) & position(V) & .my_name(MyName) & get_agents_lower_priority_same_type(MyName, SetAgents)
<- 
	.print("Sending action to ", S, " ", SetAgents);
	.send(SetAgents,tell,nextStepRepairer(MyName, V, S));
    !commitAction(Act);
    !!clearNextStepRepairer.

+!clearNextStepRepairer <-
	.abolish(nextStepRepairer(_, _, _)).
    
+!initSpecific <-
	+goodZone(10).
	
+!processBeforeStep(S) <-
	!!evaluateDisabledFriendNearby.
+!processAfterStep(S) <-
	!!testAppointmentWithDisabledAgent.


/*
 * Repair strategy
 */

/* Ask my agent if he is already repaired */
+!testAppointmentWithDisabledAgent:
	busy(Ag) & .my_name(MyName) & play(MyName,repairerLeader,"grMain")
<-
	.send(Ag,askOne,health(_), health(H));
	.abolish(health(_)[source(Ag)]);
	if (H > 0) {
		.abolish(repairerBusy(MyName));
		.abolish(iWasRepaired);
		.abolish(busy(_));
		.print("Someone repaired my agent! ", H, " ", Ag);
	}.	
+!testAppointmentWithDisabledAgent:
	busy(Ag) & play(RepairerLeader,repairerLeader,"grMain")
<-
	.send(Ag,askOne,health(_), health(H));
	.abolish(health(_)[source(Ag)]);
	if (H > 0) {
		.send(RepairerLeader, tell, iAmFree);
		.abolish(iWasRepaired);
		.abolish(busy(_));
		.print("Someone repaired my agent! ", H, " ", Ag);
	}.
+!testAppointmentWithDisabledAgent.
-!testAppointmentWithDisabledAgent <-
	.print("Error verifying my agent").

+hit(AgentName, Pos)[source(self)]:
    infinite(INF) & .my_name(AgentName)
<-
    .print(AgentName, " (me) was hit at ", Pos);
    .abolish(hit(AgentName, _));
    !clearDataRepair(AgentName);
    +closest(none, AgentName, INF);
    
    !searchRepairerToHelp(AgentName, Pos).
    
+hit(AgentName, Pos):
    infinite(INF)
<-
    .print(AgentName, " was hit at ", Pos);
    .abolish(hit(AgentName, _));
    !clearDataRepair(AgentName);
    +closest(none, AgentName, INF);
    
    !searchRepairerToHelp(AgentName, Pos).
    
    
+!searchRepairerToHelp(AgentName, Pos):
    .findall(Agent, friend(Agent, _, repairer, _), SetAgents)
<-
    .send(SetAgents, achieve, canHelp(AgentName, Pos));
    
    .wait(.count(friend(_, _, repairer, _), NProposals) & .count(pathProposal(AgentName, Pos, _, _)[source(_)], NProposals), 300, Time);
    
    .print("Received all proposals to help ", AgentName, " in ", Time);
    
	!selectNextBestRepairer(AgentName).
	
-!searchRepairerToHelp(AgentName, Pos) <-
	.print("Not received all proposals to help ", AgentName, " in 300!");
	!selectNextBestRepairer(AgentName).
    
+pathProposal(AgentName, Pos, Path, Lenght)[source(RepairerName)]:
	.my_name(MyName) & play(MyName,repairerLeader,"grMain") &
	.count(pathProposal(AgentName, Pos, _, _)[source(_)], NProposals)
<-
	.print("I got a new proposal ", pathProposal(AgentName, Pos, Path, Lenght)[source(RepairerName)], " Total: ", NProposals, " proposals for help agent ", AgentName, " so far").

//Notify the repairer with the best proposal
@notifySelectedRepairer0[atomic]
+!notifySelectedRepairer(AgentName):
    .my_name(MyName) & play(MyName,repairerLeader,"grMain") &
    closest(MyName, AgentName, Distance) & repairerBusy(MyName) & Distance < INF
<-  
    .abolish(pathProposal(_, _, _, _)[source(self)]);
    .abolish(closest(_, AgentName, _));
    .print("### The best repairer ", MyName, " is already busy!");
    !selectNextBestRepairer(AgentName).

@notifySelectedRepairer1[atomic]
+!notifySelectedRepairer(AgentName):
    closest(RepairerName, AgentName, Distance) & repairerBusy(RepairerName) & Distance < INF
<-  
    .abolish(pathProposal(_, _, _, _)[source(RepairerName)]);
    .abolish(closest(_, AgentName, _));
    .print("### The best repairer ", RepairerName, " is already busy!");
    !selectNextBestRepairer(AgentName).

@notifySelectedRepairer2[atomic]
+!notifySelectedRepairer(AgentName):
    closest(Repairer, AgentName, Distance) & Repairer \== none
<-
    +repairerBusy(Repairer);
    .send(Repairer, achieve, gotoCure(AgentName));
    
    !clearDataRepair(AgentName);
    
    .print("### Repairer ", Repairer, " is the closest to help ", AgentName, " at distance of ", Distance).
    
@notifySelectedRepairer3[atomic]
+!notifySelectedRepairer(AgentName):
    true
<-
    !clearDataRepair(AgentName);
    
    .print("### Nobody of repairers available to help ", AgentName).
    
//Evaluate the proposals and see if there is a best proposal different than infinite
+!selectNextBestRepairer(AgentName):
	.my_name(MyName) & play(MyName,repairerLeader,"grMain") &
    best_proposal_repair(AgentName, Lenght) & pathProposal(AgentName, _, _, Lenght)[source(self)] & Lenght < INF
<-
    +closest(MyName, AgentName, Lenght);
    .print("Looking for the next best repairer to help ", AgentName, ", found ", MyName);
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
    .print("Looking for the next best repairer to help ", AgentName, ", nobody found!!!!").

+!clearDataRepair(AgentName):
    true
<-
    .abolish(pathProposal(AgentName,_,_,_));
    .abolish(closest(_, AgentName, _)).

/* Repairer notifies the leader that he is enabled */
+iAmFree[source(RepairerName)] <-
	.abolish(iAmFree[source(RepairerName)]);
	.abolish(repairerBusy(RepairerName)).

/* Answer to the leader */
+!canHelp(AgentName, Pos):
    is_disabled & infinite(INF) & play(RepairerLeader,repairerLeader,"grMain")
<-
	.send(RepairerLeader, tell, pathProposal(AgentName, Pos, [], INF));
    .print("Agent ", AgentName, " needs help. I cannot go. I'm disabled."). 
    
+!canHelp(AgentName, Pos):
    .my_name(AgentName) & infinite(INF) & play(RepairerLeader,repairerLeader,"grMain")
<-
	.send(RepairerLeader, tell, pathProposal(AgentName, Pos, [], INF));
    .print("Agent ", AgentName, " needs help. I cannot repair myself.").
    
+!canHelp(AgentName, Pos):
    not busy(_) & position(MyPos) & (not zoneScore(_) | not is_good_zone_repairer(_) & zoneScore(ZoneScore))
<-
    .print("Agent ", AgentName, " needs help. I can go. ", MyPos , " -> ", Pos, ". My zone score is just ", ZoneScore);
    !calculePath(AgentName, MyPos, Pos).

+!canHelp(AgentName, Pos):
    infinite(INF) & play(RepairerLeader,repairerLeader,"grMain")
<-
	.send(RepairerLeader, tell, pathProposal(AgentName, Pos, [], INF));
    .print("Agent ", AgentName, " needs help. I cannot go.").
    
+!calculePath(AgentName, S, D):
    play(RepairerLeader,repairerLeader,"grMain")
<-
    .print("Calculating the shortest path...");
    ia.shortestPath(S, D, Path, Lenght);
    .send(RepairerLeader, tell, pathProposal(AgentName, D, Path, Lenght));
    .print("Path to help ", AgentName, " at ", D, " from ", S, " is ", Path).
    
-!calculePath(AgentName, S, D):
    infinite(INF) & play(RepairerLeader,repairerLeader,"grMain")
<- 
	.send(RepairerLeader, tell, pathProposal(AgentName, D, [], INF));
    .print("I do not know any way to go from ", S, " to ", D).    
    
@gotoCure1[atomic]
+!gotoCure(AgentName):
    not busy(_)
<-
    +busy(AgentName);
    .send(AgentName, tell, acceptedAppointment);
    .print("Going to cure ", AgentName).

+!gotoCure(AgentName):
    busy(_)
<-
    .print("I'm already busy with ", AgentName).
    
/* I'm the leader and the agent told me he is enabled now */
+iWasRepaired[source(AgentName)]: 
	.my_name(MyName) & play(MyName,repairerLeader,"grMain")
<-
	.abolish(repairerBusy(MyName));
	.abolish(iWasRepaired);
	.abolish(busy(_)).
    
/* I need to notify the leader repairer that I'm free because my agent told me he is enabled now */
+iWasRepaired[source(AgentName)]: 
	play(RepairerLeader,repairerLeader,"grMain") 
<-
	.send(RepairerLeader, tell, iAmFree);
	.abolish(iWasRepaired);
	.abolish(busy(_)).

+!evaluateDisabledFriendNearby:
	myTeam(MyTeam) & 
	position(MyV) & 
	step(S) &
	myNameInContest(MyName) & 
	is_good_zone_repairer(ZoneScore) &
	.setof(AgentName,
				ia.edge(MyV,V,_) & 
				visibleEntity(Entity, V, MyTeam, disabled) &
				Entity \== MyName &
				friend(AgentName, Entity, _, _),
			AllAgents) & .length(AllAgents, TotalOptions) & TotalOptions > 0
<-
	.print("Calling all friends ", AllAgents, " because I have a zone of ", ZoneScore);
	.send(AllAgents, tell, canCome(S)).
+!evaluateDisabledFriendNearby.	