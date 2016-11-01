//I'm settled
is_at_aim_position_hill :- at_the_hill & 
						is_linked_region_weak & 
						not is_inside_team_region_weak.

can_expand_to_hill(V) :-
        step(S) &
        token(S) &
        is_at_aim_position_hill &
        
        position(MyV) & myTeam(MyTeam) &
        ia.edge(MyV,V,_) & 
        not ia.vertex(V, MyTeam) &
        not there_is_any_enemy_at(V) &
        
        ia.edge(MyV,MyW1,_) & ia.edge(MyW1,MyY1,_) & MyV \== MyY1 & there_is_friend_at(MyY1) &
        ia.edge(V,MyW1,_) & ia.edge(MyW1,MyY1,_) & V \== MyV & V \== MyY1 & not there_is_any_enemy_at(MyW1) &
        
        ia.edge(MyV,MyW2,_) & MyW2 \== MyW1 & ia.edge(MyW2,MyY2,_) & MyV \== MyY2 & MyY2 \== MyY1 & MyY2 \== MyW1 & there_is_friend_at(MyY2) &
        ia.edge(V,MyW2,_) & ia.edge(MyW2,MyY2,_) & V \== MyY2 & not there_is_any_enemy_at(MyW2).


can_expand_to_hill(V) :-
        step(S) &
        token(S) &
        is_at_aim_position_hill &
        
        position(MyV) & myTeam(MyTeam) &
        ia.edge(MyV,V,_) & 
        not ia.vertex(V, MyTeam) &
        not there_is_any_enemy_at(V) &
        
        ia.edge(MyV,MyW1,_) & ia.edge(MyW1,MyY1,_) & MyV \== MyY1 & there_is_friend_at(MyY1) &
        ia.edge(V,W1,_) & ia.edge(W1,MyY1,_) & V \== MyV & V \== MyY1 & not there_is_any_enemy_at(W1) &
        
        ia.edge(MyV,MyW2,_) & MyW2 \== MyW1 & ia.edge(MyW2,MyY2,_) & MyV \== MyY2 & MyY2 \== MyY1 & MyY2 \== W1 & MyY2 \== MyW1 & there_is_friend_at(MyY2) &
        ia.edge(V,W2,_) & W2 \== W1 & W2 \== MyY1 & W2 \== MyW1 & ia.edge(W2,MyY2,_) & V \== MyY2 & not there_is_any_enemy_at(W2).
        
//Breaking swarm
can_expand_to_hill(V) :-
        step(S) &
        token(S) &
        is_at_aim_position_hill &
        
        zoneScore(MyZoneScore) &
        sumVertices(TotalVerticesValues) &
        MyZoneScore < TotalVerticesValues * 0.05 &
        .print("Expanding value ", MyZoneScore, " of ", TotalVerticesValues) &
        
        position(MyV) & myTeam(MyTeam) &
        ia.probedVertex(MyV,ValueMyV) &
        
        .setof(Vertex, 
                ia.edge(MyV,Vertex,_) & 
                not ia.vertex(Vertex, MyTeam) &
                not there_is_any_enemy_at(Vertex) &
                ia.probedVertex(Vertex,ValueV) &
                ValueV - ValueMyV > 2
            , Options
        ) &
        not .empty(Options) &
        .nth(math.random(TotalOptions), Options, V).
        
can_expand_to_hill(V) :-
        step(S) &
        token(S) &
        is_at_aim_position_hill &
        
        zoneScore(MyZoneScore) &
        sumVertices(TotalVerticesValues) &
        MyZoneScore < TotalVerticesValues * 0.05 &
        .print("Expanding value ", MyZoneScore, " of ", TotalVerticesValues) &
        
        position(MyV) & myTeam(MyTeam) &
        ia.probedVertex(MyV,ValueMyV) &
        
        .setof(Vertex, 
                ia.edge(MyV,Vertex,_) & 
                not ia.vertex(Vertex, MyTeam) &
                not there_is_enemy_at(Vertex) &
                ia.probedVertex(Vertex,ValueV) &
                ValueV - ValueMyV > 3
            , Options
        ) &
        not .empty(Options) &
        .nth(math.random(TotalOptions), Options, V).
        