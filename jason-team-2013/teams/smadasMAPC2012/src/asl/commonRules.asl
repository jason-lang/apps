// energy lower than the minimum energy allowed
is_energy_goal :- energy(MyE) & minEnergy(Min) & MyE < Min 
					|
				  energy(MyE) & MyE < 3 & .my_name(MyName) & friend(MyName, _, repairer) & is_disabled.
				  
is_full_energy_goal :- energy(MyE) & maxEnergy(Max) & MyE < Max.

// some edge to adjacent vertex is not surveyed
is_survey_goal :- position(MyV) & 
                  (
                    infinite(INF) & ia.edge(MyV,_,INF)
                  | 
                    maxWeight(MAXWEIGHT) & ia.edge(MyV,_,MAXWEIGHT)
                  ).

// test if the agent is disabled
is_disabled :- health(MyHealth) & MyHealth <= 0.

there_is_disable_friend_at_same_vertex_as_repairer(V) :- myTeam(MyTeam) & myNameInContest(MyName) &
                                visibleEntity(Entity, V, MyTeam, disabled) &
                                Entity \== MyName &
                                visibleEntity(EntityRepairer, V, MyTeam, _) &
                                EntityRepairer \== MyName &
                                friend(_, EntityRepairer, repairer) & 
                                EntityRepairer \== Entity.

// test if there is a dangerous enemy at the same vertex. A dangerous enemy is an unknown enemy or a Saboteur.
// Obs.: It isn't used by the saboteurs
is_leave_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) & Team \== MyTeam & (entityType(Entity, "Saboteur") | not entityType(Entity, _) | is_suspect(Entity)).

// test if don't have any direction to go with the edge already surveyed (W != INF)
no_way_to_go :- position(MyV) & infinite(INF) &
                .setof(V, ia.edge(MyV,V,W) & W \== INF, []).
                
// test if the agent is at the destination vertex to be repaired
is_destination_repair_vertex(RepairerName) :- position(MyV) & gotoVertexRepair(MyV,RepairerName,_).

// test if the agent is next to the destination vertex to be repaired
is_next_destination_repair_vertex :- gotoVertexRepair(_,_,[D|T]) & position(MyV) & ia.edge(MyV,D,_) & not .member(MyV,T).

//Verify if there is some dangerous enemies at vertex Op. A dangerous enemy is an unknown enemy or a Saboteur 
there_is_enemy_at(Op) :- myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam & (entityType(Entity, "Saboteur") | not entityType(Entity, _) | is_suspect(Entity)).


there_is_enemy_neighborhood(U) :- ia.edge(U,V,_) & there_is_enemy_at(V).
there_is_dangerous_enemy_at(Op) :- myTeam(MyTeam) & visibleEntity(Entity, Op, Team, normal) & Team \== MyTeam & (entityType(Entity, "Saboteur") | is_suspect(Entity)).
there_is_friend_at(Op) :- myTeam(MyTeam) & 
                            visibleEntity(Entity, Op, MyTeam, normal).
there_is_friend_at(Op) :-
            .my_name(MyAgentName) &
            friend(AgentName, _, _) & 
            MyAgentName \== AgentName & 
            generalPriority(AgentName, Id) & 
            ia.getAgentPosition(Id, Op).
            
            
there_is_friend_at_who(Op, Entity) :- myTeam(MyTeam) & 
                            visibleEntity(Entity, Op, MyTeam, normal).
there_is_friend_at_who(Op, Entity) :-
            .my_name(MyAgentName) &
            friend(AgentName, Entity, _) & 
            MyAgentName \== AgentName & 
            generalPriority(AgentName, Id) & 
            ia.getAgentPosition(Id, Op).
            

there_is_any_enemy_at(Op) :- 
    myTeam(MyTeam) & 
    visibleEntity(Entity, Op, Team, normal) & 
    Team \== MyTeam.
    
there_is_any_enemy_at(Op) :-    
    ia.visibleEnemy(Entity, Op).

//Verify if there is some repairer at vertex Op.
there_is_repairer_at(Op) :- myTeam(MyTeam) & myNameInContest(MyName) & 
                            visibleEntity(Entity, Op, MyTeam, _) & friend(_, Entity, repairer) & MyName \== Entity.

//Get the list of vertices with the value                           
list_vertex_by_value(Value, List) :- .setof(V, ia.probedVertex(V,Value), List).

//Test if I'm the same position for a long time
is_heartbeat_goal :- stepsSamePosition(Pos, T) & step(S) & S - T > 25.

//I'm going to be repaired by someone
is_route_repaired_goal  :- gotoVertexRepair(_, _, [_|T]) & not .empty(T).

/* This rules are used to force the agent to move for a good place */
//I'm settled
is_at_swarm_position_test :- noMoreVertexToProbe & is_at_swarm_position & is_linked_region_weak & not is_inside_team_region_weak.

//I'm at swarm position
is_at_swarm_position :- position(Pos) & allowedArea(NeighborhoodOutside, NeighborhoodInside) & (.member(Pos, NeighborhoodOutside) | .member(Pos, NeighborhoodInside)).

//I'm inside of team region
is_inside_team_region :- 
                         (
                            there_is_friend_more_priority
                            |
                            is_inside_team_friends
                         ).
                         
is_inside_team_region_weak :- 
                         (
                            (there_is_friend_more_priority_nearby | there_is_friend_more_priority) 
                            |
                            is_inside_team_friends
                         ).
                         
is_inside_team_friends :- not (position(MyV) & myTeam(MyTeam) & ia.edge(MyV,V,_) & ia.vertex(V, Team) & MyTeam \== Team).
is_inside_team_friends_vertex(U) :- not (myTeam(MyTeam) & ia.edge(U,V,_) & ia.vertex(V, Team) & MyTeam \== Team).


is_inside_team_region_walk :- is_inside_team_region_weak.

//I'm linked with at least 2 vertex of my team
is_linked_region :- position(MyV) & myTeam(MyTeam) &
                    .setof(V, 
                           ia.edge(MyV,V,_) & ia.vertex(V, MyTeam), 
                           Options
                    ) & .length(Options, TotalVertexMyTeam) & TotalVertexMyTeam >= 2.
                    
//I'm linked with at least 2 vertex of my team, but there are no friends there
is_linked_region_weak :- position(MyV) & myTeam(MyTeam) &
                    .setof(V, 
                           ia.edge(MyV,V,_) & ia.vertex(V, MyTeam) & not visibleEntity(_, V, MyTeam, normal), 
                           Options
                    ) & .length(Options, TotalVertexMyTeam) & TotalVertexMyTeam >= 2.

//I'm linked with at least 3 vertex of my team, but there are no friends there, and there is some area formed
is_linked_region_weak_very_weak :- position(MyV) & myTeam(MyTeam) &
                    .setof(V, 
                           ia.edge(MyV,V,_) & ia.vertex(V, MyTeam) & not visibleEntity(_, V, MyTeam, normal), 
                           Options
                    ) & .length(Options, TotalVertexMyTeam) & 
                    TotalVertexMyTeam > 2.

//I'm linked with at least 2 vertex of my team, but there are no friends there, and there is 2 different friends in the far vertex                  
is_linked_region_weak_weakest :- position(MyV) & myTeam(MyTeam) &
                           ia.edge(MyV,V,_) & ia.vertex(V, MyTeam) & not visibleEntity(_, V, MyTeam, normal) &
                           ia.edge(V,W,_) & get_position_agent_name(AgentName, W) &
                           MyV \== W &
                           
                           ia.edge(MyV,V2,_) & ia.vertex(V2, MyTeam) & not visibleEntity(_, V2, MyTeam, normal) &
                           V2 \== V &
                           ia.edge(V2,W2,_) & MyV \== W2 & W2 \== W & get_position_agent_name(AgentName2, W2).
            
//There are more friends with priority at the same vertex. I'm going to wait
there_is_friend_more_priority :- position(MyV) & .my_name(MyName) & myTeam(MyTeam) & myNameInContest(MyNameContest) & 
                                visibleEntity(Entity, MyV, MyTeam, normal) & MyNameContest \== Entity &
                                friend(FriendName, Entity, _) &
                                generalPriority(MyName, MyPriority) &
                                generalPriority(FriendName, MyFriendPriority) &
                                MyFriendPriority < MyPriority.
                                
there_are_more_friends :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyNameContest) & 
                                visibleEntity(Entity, MyV, MyTeam, normal) & MyNameContest \== Entity.
                                
there_is_friend_more_priority_nearby :- position(MyV) & .my_name(MyName) & myTeam(MyTeam) & myNameInContest(MyNameContest) &
                                ia.edge(MyV,V,_) & 
                                visibleEntity(Entity, V, MyTeam, normal) & MyNameContest \== Entity &
                                friend(FriendName, Entity, _) &
                                generalPriority(MyName, MyPriority) &
                                generalPriority(FriendName, MyFriendPriority) &
                                MyFriendPriority < MyPriority.
                                
there_are_more_friends_nearby :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyNameContest) & 
                                ia.edge(MyV,V,_) & 
                                visibleEntity(Entity, V, MyTeam, normal) & MyNameContest \== Entity.

is_almost_full_map :- noMoreVertexToProbe & step(S) & S > 200 & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.8.
is_almost_full_map :- noMoreVertexToProbe & step(S) & S > 100 & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.9.

is_good_map_conquered :- is_almost_full_map.
is_good_map_conquered :- step(S) & S > 200 & noMoreVertexToProbe & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.32 & at_some_good_zone_score(0.34).
is_good_map_conquered :- step(S) & S > 130 & noMoreVertexToProbe & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.35 & at_some_good_zone_score(0.35).
is_good_map_conquered :- step(S) & S > 80 & noMoreVertexToProbe & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.38 & at_some_good_zone_score(0.35).
is_good_map_conquered :- step(S) & S > 25 & noMoreVertexToProbe & sumVertices(Total) & zonesScore(Score) & Score >= Total * 0.4 & at_some_good_zone_score(0.35).

at_some_good_zone_score(Perc) :- zonesScore(Score) & zoneScore(MyZoneScore) & (MyZoneScore / Score) >= Perc.
                      
//there is enemy inside my good area
there_is_enemy_inside_my_good_area(V) :- 
                                      ((visibleEntity(Entity, V, Team, normal) | ia.visibleEnemy(Entity, V)) & not friend(_, Entity, _) & (entityType(Entity, "Saboteur") | not entityType(Entity, _) | is_suspect(Entity))) & 
                                      allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                      (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)).
                                      
there_is_enemy_inside_my_good_area(V) :- 
                                      ((visibleEntity(Entity, V, Team, normal) | ia.visibleEnemy(Entity, V)) & not friend(_, Entity, _)) & 
                                      allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                      (.member(V, NeighborhoodOutside) | .member(V, NeighborhoodInside)).
                                      
is_dangerous_entity(Entity) :- myTeam(MyTeam) & entity(Entity, _, Team, _) & Team \== MyTeam & (not entityType(Entity, _) | entityType(Entity, "Saboteur") | is_suspect(Entity)).

get_vertex_to_go_repair_forever_alone(D, Path) :- position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
                                            .setof(V,
                                                visibleEntity(Entity, V, MyTeam, _) & 
                                                friend(_, Entity, repairer) & Entity \== MyName
                                            ,List) &
                                            not .empty(List) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) &
                                            Lenght > 2.

get_vertex_to_go_repair_forever_alone(D, Path) :- position(MyV)  & .my_name(MyAgentName) & .setof(V, 
                                                friend(AgentName, _, repairer) & generalPriority(AgentName, Id) &
                                                AgentName \== MyAgentName &
                                                ia.getAgentPosition(Id, V)
                                                , List
                                            ) &
                                            ia.shortestPathDijkstraCompleteTwo(MyV, List, D, Path, Lenght) & 
                                            Lenght > 2.
                                            
is_suspect(Entity) :- suspect(Entity) & not entityType(Entity, _).

get_position_agent_entity(Entity, Pos) :-
    friend(AgentName, Entity, _) & generalPriority(AgentName, Id) &
    ia.getAgentPosition(Id, Pos).
    
get_position_agent_name(AgentName, Pos) :-
    friend(AgentName, _, _) & generalPriority(AgentName, Id) &
    ia.getAgentPosition(Id, Pos).
    
there_is_my_saboteur_at(V) :-  myTeam(MyTeam) & myNameInContest(MyName) &
                            visibleEntity(Entity, V, MyTeam, normal) &
                            friend(_, Entity, saboteur) & MyName \== Entity.
                            
get_vertex_to_go_swarm(D, Path) :- position(MyV) & myTeam(MyTeam) & 
                                                allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                                not .empty(NeighborhoodOutside) &
                                                ia.shortestPathDijkstraCompleteTwo(MyV, NeighborhoodOutside, D, Path, Lenght) &
                                                Lenght > 1.
                                
                                
get_path_to_some_border_vertex(D, Path) :- position(MyV) & myTeam(MyTeam) &
                                            lastMoveInsideToOutside(D) &
                                            ia.shortestPath(MyV, D, Path, Lenght) &
                                            Lenght > 2.
                                                
get_path_to_some_border_vertex(D, Path) :- position(MyV) & myTeam(MyTeam) &
                                            allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            not .empty(NeighborhoodOutside) &
                                            .setof(V,
                                                .member(V, NeighborhoodOutside) &
                                                not ia.vertex(V, MyTeam)
                                            ,List) &
                                            .length(List, TotalOptions) & TotalOptions > 0 &
                                            .nth(math.random(TotalOptions), List, D) &
                                            ia.shortestPath(MyV, D, Path, Lenght) &
                                            Lenght > 2.
                                            
get_path_to_some_border_vertex(D, Path) :- position(MyV) & myTeam(MyTeam) &
                                            allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            not .empty(NeighborhoodOutside) &
                                            .setof(V,
                                                .member(V, NeighborhoodOutside) 
                                            ,List) &
                                            .length(List, TotalOptions) & TotalOptions > 0 &
                                            .nth(math.random(TotalOptions), List, D) &
                                            ia.shortestPath(MyV, D, Path, Lenght) &
                                            Lenght > 2.
                                            
get_path_to_some_inside_vertex(D, Path) :- position(MyV) & myTeam(MyTeam) &
                                            allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            not .empty(NeighborhoodOutside) &
                                            .setof(V,
                                                .member(V, NeighborhoodOutside) & 
                                                ia.vertex(V, MyTeam) &
                                                is_inside_team_friends_vertex(V)
                                            ,List) &
                                            .length(List, TotalOptions) & TotalOptions > 0 &
                                            .nth(math.random(TotalOptions), List, D) &
                                            ia.shortestPath(MyV, D, Path, Lenght) &
                                            Lenght > 2.
                                            
get_path_to_some_inside_vertex(D, Path) :- position(MyV) & myTeam(MyTeam) &
                                            allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            not .empty(NeighborhoodOutside) &
                                            .setof(V,
                                                .member(V, NeighborhoodOutside) & 
                                                ia.vertex(V, MyTeam) &
                                                not there_is_friend_at(V) 
                                            ,List) &
                                            .length(List, TotalOptions) & TotalOptions > 0 &
                                            .nth(math.random(TotalOptions), List, D) &
                                            ia.shortestPath(MyV, D, Path, Lenght) &
                                            Lenght > 2.
                                            
get_path_to_some_inside_vertex(D, Path) :- position(MyV) & myTeam(MyTeam) &
                                            allowedArea(NeighborhoodOutside, NeighborhoodInside) &
                                            not .empty(NeighborhoodOutside) &
                                            .setof(V,
                                                .member(V, NeighborhoodOutside) & 
                                                ia.vertex(V, MyTeam) 
                                            ,List) &
                                            .length(List, TotalOptions) & TotalOptions > 0 &
                                            .nth(math.random(TotalOptions), List, D) &
                                            ia.shortestPath(MyV, D, Path, Lenght) &
                                            Lenght > 2.
                                            
going_swarm_inside_goal :- position(MyV) & myTeam(MyTeam) &
                            ia.edge(MyV,V,_) & 
                            not ia.vertex(V, MyTeam).
                            
there_are_more_friends_than_enemies(V) :-
                            myTeam(MyTeam) &
                            .count((visibleEntity(Entity, V, MyTeam, normal)), NFriend) &
                            .count((visibleEntity(EntityEnemy, V, Team, normal) & Team \== MyTeam), NEnemy) &
                            NFriend > NEnemy.
                            
there_are_more_friends_than_enemies_my_position :-
                            position(MyV) & there_are_more_friends_than_enemies(MyV).
                            
get_all_best_vertex(List) :- bestProbedVertex(V, Value) & 
                            .setof(Vertex, ia.probedVertex(Vertex,Value), List).
                        
there_are_friends_near(U) :-
            .my_name(MyAgentName) &
            myNameInContest(MyName) &
            myTeam(MyTeam) &
            ia.edge(U,V,_) &
            (
                visibleEntity(Entity, V, MyTeam, _) & MyName \== Entity |
                friend(AgentName, _, _) & MyAgentName \== AgentName & generalPriority(AgentName, Id) & ia.getAgentPosition(Id, V)
            ).
            
there_are_friends_saboteurs_near(U) :-
            .my_name(MyAgentName) &
            myNameInContest(MyName) &
            myTeam(MyTeam) &
            (
                (
                    visibleEntity(Entity, U, MyTeam, _) & MyName \== Entity & friend(_, Entity, saboteur) |
                    friend(AgentName, _, saboteur) & MyAgentName \== AgentName & generalPriority(AgentName, Id) & ia.getAgentPosition(Id, U)
                )
            |
                ia.edge(U,V,_) &
                (
                    visibleEntity(Entity, V, MyTeam, _) & MyName \== Entity & friend(_, Entity, saboteur) |
                    friend(AgentName, _, saboteur) & MyAgentName \== AgentName & generalPriority(AgentName, Id) & ia.getAgentPosition(Id, V)
                )
            ).
            
there_are_friends_saboteurs_at(V) :-
            myTeam(MyTeam) &
            myNameInContest(MyName) &
            visibleEntity(Entity, V, MyTeam, normal) &
            MyName \== Entity &
            friend(_, Entity, saboteur).

can_expand_to(V) :-
        step(S) &
        token(S) &
        
        position(MyV) & myTeam(MyTeam) &
        ia.edge(MyV,V,_) & 
        not ia.vertex(V, MyTeam) &
        not there_is_any_enemy_at(V) &
        
        ia.edge(MyV,MyW1,_) & ia.edge(MyW1,MyY1,_) & MyV \== MyY1 & there_is_friend_at(MyY1) &
        ia.edge(V,MyW1,_) & ia.edge(MyW1,MyY1,_) & V \== MyV & V \== MyY1 & not there_is_any_enemy_at(MyW1) &
        
        ia.edge(MyV,MyW2,_) & MyW2 \== MyW1 & ia.edge(MyW2,MyY2,_) & MyV \== MyY2 & MyY2 \== MyY1 & MyY2 \== MyW1 & there_is_friend_at(MyY2) &
        ia.edge(V,MyW2,_) & ia.edge(MyW2,MyY2,_) & V \== MyY2 & not there_is_any_enemy_at(MyW2).


can_expand_to(V) :-
        step(S) &
        token(S) &
        
        position(MyV) & myTeam(MyTeam) &
        ia.edge(MyV,V,_) & 
        not ia.vertex(V, MyTeam) &
        not there_is_any_enemy_at(V) &
        
        ia.edge(MyV,MyW1,_) & ia.edge(MyW1,MyY1,_) & MyV \== MyY1 & there_is_friend_at(MyY1) &
        ia.edge(V,W1,_) & ia.edge(W1,MyY1,_) & V \== MyV & V \== MyY1 & not there_is_any_enemy_at(W1) &
        
        ia.edge(MyV,MyW2,_) & MyW2 \== MyW1 & ia.edge(MyW2,MyY2,_) & MyV \== MyY2 & MyY2 \== MyY1 & MyY2 \== W1 & MyY2 \== MyW1 & there_is_friend_at(MyY2) &
        ia.edge(V,W2,_) & W2 \== W1 & W2 \== MyY1 & W2 \== MyW1 & ia.edge(W2,MyY2,_) & V \== MyY2 & not there_is_any_enemy_at(W2).
        
//Breaking swarm
can_expand_to(V) :-
        step(S) &
        token(S) &
        zoneScore(MyZoneScore) &
        sumVertices(TotalVerticesValues) &
        MyZoneScore < TotalVerticesValues * 0.02 &
        .print("Expanding value ", MyZoneScore, " of ", TotalVerticesValues) &
        
        allowedArea(NeighborhoodOutside, NeighborhoodInside) &
        
        position(MyV) & myTeam(MyTeam) &
        ia.probedVertex(MyV,ValueMyV) &
        
        .setof(Vertex, 
                ia.edge(MyV,Vertex,_) & 
                not ia.vertex(Vertex, MyTeam) &
                not there_is_any_enemy_at(Vertex) &
                ia.probedVertex(Vertex,ValueV) &
                ValueV - ValueMyV > 2 &
                (.member(Vertex, NeighborhoodOutside) | .member(Vertex, NeighborhoodInside))
            , Options
        ) &
        not .empty(Options) &
        .max(Options,V).
        
can_expand_to(V) :-
        step(S) &
        token(S) &
        allowedArea(NeighborhoodOutside, NeighborhoodInside) &
        zoneScore(MyZoneScore) &
        sumVertices(TotalVerticesValues) &
        MyZoneScore < TotalVerticesValues * 0.02 &
        .print("Expanding value ", MyZoneScore, " of ", TotalVerticesValues) &
        
        position(MyV) & myTeam(MyTeam) &
        ia.probedVertex(MyV,ValueMyV) &
        
        .setof(Vertex, 
                ia.edge(MyV,Vertex,_) & 
                not ia.vertex(Vertex, MyTeam) &
                not there_is_enemy_at(Vertex) &
                ia.probedVertex(Vertex,ValueV) &
                ValueV - ValueMyV > 3 &
                (.member(Vertex, NeighborhoodOutside) | .member(Vertex, NeighborhoodInside))
            , Options
        ) &
        not .empty(Options) &
        .max(Options,V).
     
get_next_agent_token(Agent) :-
    .my_name(MyName) & 
    generalPriority(MyName, 28) &
    generalPriority(Agent, 1).

get_next_agent_token(Agent) :-
    .my_name(MyName) &
    generalPriority(MyName, MyPriority) &
    generalPriority(Agent, MyPriority + 1). 
