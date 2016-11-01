// Test if I need energy
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min.

// Some edge to adjacent vertex is not surveyed
is_survey_goal :- not is_disabled & position(MyV) & 
                  (
                    infinite(INF) & ia.edge(MyV,_,INF)
                  | 
                    maxWeight(MAXWEIGHT) & ia.edge(MyV,_,MAXWEIGHT)
                  ).
                  
// Test if the agent is disabled
is_disabled :- health(MyHealth) & MyHealth <= 0.

// Check if Agent1 has higher priority than Agent2
priorityEntity(Agent1, Agent2) :- friend(Agent1, _, _, Priority1) &
								friend(Agent2, _, _, Priority2) &
								Priority1 > Priority2.
								
								
// Number of agents higher priority
number_agents_higher_priority_same_type(Agent, C) :-
							.count(friend(Agent, _, Type, Priority) &
						 			friend(Agent2, _, Type, Priority2) &
						    		Priority > Priority2, C).

// Get the set of agents with lower priority
get_agents_lower_priority_same_type(Agent, SetAgents) :-
							.findall(Agent2,friend(Agent, _, Type, Priority) &
						 			friend(Agent2, _, Type, Priority2) &
						    		Priority < Priority2, SetAgents).
						    		
// Test if there is no more vertices to probe
noMoreVertexToProbe :- goalState(_,probeAll,_,_,satisfied).
						    		
						    		
/*
 * If I'm at some vertex with an enemy saboteur, so I count how many friends are there too.
 * I choose to leave or to parry using probability.
 * The probability to execute parry is: 1.0 / N, where N is the amount of friends
 */ 						    		
is_parry_goal :- not is_disabled & position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) &
         				Team \== MyTeam & entityType(Entity, "Saboteur", _, _, _) &
         				there_is_more_enemies_than_friends(MyV) &
         				.count(visibleEntity(_, MyV, MyTeam, normal), N) &
         				.random(K) & K <= (1.0 / N).
there_is_more_enemies_than_friends(V) :-
                            myTeam(MyTeam) &
                            .count((visibleEntity(Entity, V, MyTeam, normal) & friend(_, Entity, saboteur, _)), NFriend) &
                            .count((visibleEntity(EntityEnemy, V, Team, normal) & Team \== MyTeam & entityType(EntityEnemy, "Saboteur", _, _, _)), NEnemy) &
                            NEnemy > NFriend.
//That's the same idea for agents who can't parry, but they need to leave                  
is_leave_goal :- not is_disabled & position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) &
         				Team \== MyTeam & entityType(Entity, "Saboteur", _, _, _) &
         				there_is_more_enemies_than_friends(MyV).
         
//Check if there are visible saboteurs at some vertex
there_are_friends_saboteurs_at(V) :-
            myTeam(MyTeam) &
            myNameInContest(MyName) &
            visibleEntity(Entity, V, MyTeam, normal) &
            MyName \== Entity &
            friend(_, Entity, saboteur, _).

//Check if there are visible saboteurs near at some vertex            
there_are_friends_saboteurs_near(U) :-
            .my_name(MyAgentName) &
            myNameInContest(MyName) &
            myTeam(MyTeam) &
            (
                (
                    visibleEntity(Entity, U, MyTeam, _) & MyName \== Entity & friend(_, Entity, saboteur, _) |
                    friend(AgentName, _, saboteur, Id) & MyAgentName \== AgentName & ia.getAgentPosition(Id, U)
                )
            |
                ia.edge(U,V,_) &
                (
                    visibleEntity(Entity, V, MyTeam, _) & MyName \== Entity & friend(_, Entity, saboteur, _) |
                    friend(AgentName, _, saboteur, Id) & MyAgentName \== AgentName & ia.getAgentPosition(Id, V)
                )
            ).
            
            
//Verify if there is some dangerous enemies at vertex Op. A dangerous enemy is an unknown enemy or a Saboteur 
there_is_enemy_at(Op) :- myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam & (entityType(Entity, "Saboteur") | not entityType(Entity, _)).


//If I'm disabled and there is a repairer at the same vertex, so I'm going to wait
is_wait_repair_goal(MyV) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.

//If I'm disabled and I'm not a repairer and there is a repairer at some adjacent vertex, so I'm going to wait
is_wait_repair_goal(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & not friend(_, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.
               
//If I'm disabled and I'm a repairer and there is an ENABLED repairer at some adjacent vertex, so I'm going to wait
is_wait_repair_goal(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & friend(_, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, normal) & friend(_, Entity, repairer, _) & Entity \== MyName.
               
//If I'm disabled and I'm a repairer and there is an DISABLED repairer at some adjacent vertex, so I'm going to wait if he has more priority
is_wait_repair_goal(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & friend(MyAgentName, MyName, repairer, _) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(EntityAgentName, Entity, repairer, _) & Entity \== MyName &
               priorityEntity(EntityAgentName, MyAgentName).
               
               
               
//Test if there is some repairer around me, so I don't need to call others
there_is_repairer_nearby(MyV) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.
there_is_repairer_nearby(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(_, Entity, repairer, _) & Entity \== MyName.               