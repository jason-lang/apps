// Test if I need energy
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min 
					|
				  .my_name(MyName) & friend(MyName, _, repairer, _) & is_disabled & energy(MyE) & MyE < 3
				    |
				  .my_name(MyName) & friend(MyName, _, saboteur, _) & energy(MyE) & minEnergy(Min) & visRange(Vis) & Vis > 1 & MyE < 5. //4 is the max distance that saboteurs attack

// Some edge to adjacent vertex is not surveyed
is_survey_goal :- not is_disabled & position(MyV) & 
                  (
                    infinite(INF) & ia.edge(MyV,_,INF)
                  | 
                    maxWeight(MAXWEIGHT) & ia.edge(MyV,_,MAXWEIGHT)
                  ).
                  
// Test if the agent is disabled
is_disabled :- (health(MyHealth)[source(percept)] | health(MyHealth)[source(self)]) & MyHealth <= 0.

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
noMoreVertexToProbe :- not ia.thereIsUnprobedVertex.
						    		
						    		
/*
 * If I'm at some vertex with an enemy saboteur, so I count how many friends are there too.
 * I choose to leave or to parry using probability.
 * The probability to execute parry is: 1.0 / N, where N is the amount of friends
 */ 						    		
 
// MODIFICACOES
is_parry_goal :- not is_disabled & position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) &
         				Team \== MyTeam & entityType(Entity, "Saboteur", _, _, _) &
         				there_is_more_enemies_than_friends(MyV) &
         				.count(visibleEntity(_, MyV, MyTeam, normal), N) &
         				.count((ia.edge(MyV,V,_) & visibleEntity(_,V,MyTeam,normal)),M) &
         				.random(K) & K <= ((1.0 / M) /* + 1.0 /N */).
         				
         				
          				
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
            
there_are_friends_saboteurs_at(V) :-
            .my_name(MyAgentName) &
            friend(AgentName, _, saboteur, Id) & MyAgentName \== AgentName & ia.getAgentPosition(Id, V).

//Check if there are visible saboteurs near at some vertex            
there_are_friends_saboteurs_near(U) :-
            .my_name(MyAgentName) &
            myNameInContest(MyName) &
            myTeam(MyTeam) &
            (
                (
                    visibleEntity(Entity, U, MyTeam, _) & MyName \== Entity & friend(_, Entity, saboteur, _) 
                    |
                    friend(AgentName, _, saboteur, Id) & MyAgentName \== AgentName & ia.getAgentPosition(Id, U)
                )
            |
                ia.edge(U,V,_) &
                (
                    visibleEntity(Entity, V, MyTeam, _) & MyName \== Entity & friend(_, Entity, saboteur, _) 
                    |
                    friend(AgentName, _, saboteur, Id) & MyAgentName \== AgentName & ia.getAgentPosition(Id, V)
                )
            ).
            
            
//Verify if there is some dangerous enemies at vertex Op. A dangerous enemy is an unknown enemy or a Saboteur 
there_is_enemy_at(Op) :- 
	myTeam(MyTeam) & 
	visibleEntity(Entity, Op, Team, normal) & 
	Team \== MyTeam & 
	(entityType(Entity, "Saboteur", _, _, _) | not entityType(Entity, _, _, _, _)).

//Verify if there is any kind of enemy at vertex Op               
there_is_any_enemy_at(Op) :- 
    myTeam(MyTeam) & 
    visibleEntity(Entity, Op, Team, normal) & 
    Team \== MyTeam.
there_is_any_enemy_at(Op) :-    
    ia.visibleEnemy(Entity, Op).
    
//Verify if there is some friend at vertex Op
there_is_friend_at(Op) :- myTeam(MyTeam) & visibleEntity(Entity, Op, MyTeam, normal).
there_is_friend_at(Op) :-
            .my_name(MyAgentName) &
            friend(AgentName, _, _, Id) & 
            MyAgentName \== AgentName & 
            ia.getAgentPosition(Id, Op).
    
    
is_good_map_conquered :- step(S) & S > 300 & is_free_to_walk & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.45 & at_some_good_zone_score(0.34).
is_good_map_conquered :- step(S) & S > 150 & is_free_to_walk & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.47 & at_some_good_zone_score(0.35).
is_good_map_conquered :- step(S) & S > 80 & is_free_to_walk & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.49 & at_some_good_zone_score(0.35).
is_good_map_conquered :- step(S) & S > 25 & is_free_to_walk & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.55 & at_some_good_zone_score(0.35).

at_some_good_zone_score(Perc) :- not is_disabled & zonesScore(Score) & zoneScore(MyZoneScore) & (MyZoneScore / Score) >= Perc.



there_are_enemies_saboteurs_near(U) :-
            .my_name(MyAgentName) &
            myNameInContest(MyName) &
            myTeam(MyTeam) &
            (
                (
                    visibleEntity(Entity, U, Team, _) & Team \== MyTeam & entityType(Entity, "Saboteur", _, _, _) 
                    |
                    ia.visibleEnemy(Entity, U) & entityType(Entity, "Saboteur", _, _, _)
                )
            |
                ia.edge(U,V,_) &
                (
                    visibleEntity(Entity, V, Team, _) & Team \== MyTeam & entityType(Entity, "Saboteur", _, _, _) 
                    |
                    ia.visibleEnemy(Entity, V) & entityType(Entity, "Saboteur", _, _, _)
                )
            ).
            