{ include("mod.common.asl") }

//Inspecionar agentes distantes
/* É muito ruim dar inspect a distância, perde muito
is_inspect_goal(Entity) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, V, Team, _) & Team \== MyTeam & ia.edge(MyV,V,_) 
                  & not entityType(Entity, _) &
                  not (
                  	visibleEntity(EntityFriend, V, MyTeam, normal) & 
                  	friend(AgentName, EntityFriend, inspector, _) &
                  	EntityFriend \== MyName & 
                  	priorityEntity(AgentName, MyAgentName)
                  ). */

//There is no priority because one of them can fail
is_inspect_goal(V) :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, V, Team, _) & Team \== MyTeam & ia.edge(MyV,V,_) 
                  & not entityType(Entity, _).
                  
is_inspect_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, _) & Team \== MyTeam
				  & not entityType(Entity, _).

+!wait_and_select_goal <- !select_goal.
-!wait_and_select_goal[error(deadline_reached)] <- .print("Deadline reached"); !select_goal.

+!select_goal: is_energy_goal 
		<- !init_goal(recharge).
+!select_goal: is_inspect_goal //TODO verificar quando tem sabotador? Tem apenas 4 sabotadores, é necessário se preocupar?
		<- !init_goal(inspect).
+!select_goal: is_inspect_goal(Op)
		<- !init_goal(goto(Op)).
+!select_goal: is_survey_goal & not is_leave_goal
		<- !init_goal(survey).
+!select_goal                  
		<- !init_goal(random_walk).
		
+inspectedEntity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange):
    step(S) & not myTeam(Team)
<-
    !broadcastInspect(Entity, Type);
    .print("The entity ", Entity, " was inspected Energy (", Energy, ",", MaxEnergy, ") Health (", Health, ",", MaxHealth, ") Strength ", Strength).

+!broadcastInspect(Entity, Type):
    not entityType(Entity, Type) & .findall(Agent, friend(Agent, _, _, _), SetAgents)
<-
    .print("Sending inspected entity in broadcast ", Entity, " ", Type);
    .send(SetAgents, tell,entityType(Entity, Type)).
+!broadcastInspect(Entity, Type): true <- true.
		
/*
 * These functions must be dependent of each kind of agent because they will
 * need to share some information with the other friends of the same kind
 */
@do0[atomic]
+!do(Act): 
    step(S) & stepDone(S)
<- 
    .print("ERROR! I already performed an action for this step! ", S).

@do1[atomic]
+!do(Act): 
    true
<- 
    !commitAction(Act).