/* I'm surrounded by friends */
is_inside_team_friends :- not (position(MyV) & myTeam(MyTeam) & ia.edge(MyV,V,_) & ia.vertex(V, Team) & MyTeam \== Team).

/* I count also when there are friends too close of me */
is_inside_team_region_weak :- 
                         (
                            (there_is_friend_more_priority_nearby | there_is_friend_more_priority) 
                            |
                            is_inside_team_friends
                         ).

/* The vertex U is surrounded by friends */
is_inside_team_friends_vertex(U) :- not (myTeam(MyTeam) & ia.edge(U,V,_) & ia.vertex(V, Team) & MyTeam \== Team).

/* I can expand if the aim vertex belongs to our team */
can_expand_aim_vertex :- aim_vertex_belongs_to_us(_).

/* Test if I'm walking inside a region of friends */
is_inside_team_region_walk :- is_inside_team_region_weak.
					
//I'm settled
is_at_aim_position :- can_expand_aim_vertex & 
						is_linked_region_weak & 
						not is_inside_team_region_weak.
						
//I'm linked with at least 2 vertex of my team, but there are no friends there
is_linked_region_weak :- position(MyV) & myTeam(MyTeam) &
                    .setof(V, 
                           ia.edge(MyV,V,_) & ia.vertex(V, MyTeam) & not visibleEntity(_, V, MyTeam, normal), 
                           Options
                    ) & .length(Options, TotalVertexMyTeam) & TotalVertexMyTeam >= 2.
                    
//I'm weak connected also if I'm in a vertex with grade 2 or it is an island and there is no 2 neighbor vertices with no friends
is_linked_region_weak :- is_linked_thin_edge.
is_linked_thin_edge :- position(MyV) & myTeam(MyTeam) &
                    .setof(V, 
                           ia.edge(MyV,V,_) & ia.vertex(V, MyTeam) & not visibleEntity(_, V, MyTeam, normal), 
                           Options
                    ) & .length(Options, TotalVertexMyTeam) & TotalVertexMyTeam >= 1 &
                    (ia.isIsland(MyV) | ia.getVertexGrade(MyV, Grade) & Grade <= 2) &
                    not (
                    	ia.edge(MyV,V,_) & not ia.vertex(V, MyTeam) &
                    	ia.edge(MyV,V2,_) & not ia.vertex(V2, MyTeam) &
                    	V \== V2
                    ).
                    
                    
//There are more friends with priority at the same vertex. I'm going to wait
there_is_friend_more_priority :- position(MyV) & .my_name(MyName) & myTeam(MyTeam) &
								friend(MyName, MyNameContest, _, MyPriority) & 
                                visibleEntity(Entity, MyV, MyTeam, normal) & MyNameContest \== Entity &
                                friend(_, Entity, _, MyFriendPriority) &
                                MyFriendPriority < MyPriority.
                    
//There are more friends with priority at the some vertex around mine. I'm going to wait
there_is_friend_more_priority_nearby :- position(MyV) & .my_name(MyName) & myTeam(MyTeam) & 
								friend(MyName, MyNameContest, _, MyPriority) & 
                                ia.edge(MyV,V,_) & 
                                visibleEntity(Entity, V, MyTeam, normal) & MyNameContest \== Entity &
                                friend(_, Entity, _, MyFriendPriority) &
                                MyFriendPriority < MyPriority.
                                
                                
can_expand_to(V) :-
        step(S) &
        token(S) &
		can_expand_aim_vertex &
		is_linked_thin_edge &
		ia.edge(MyV,V,_) &
		not ia.vertex(V, MyTeam) &
        not there_is_any_enemy_at(V).
                    
can_expand_to(V) :-
        step(S) &
        token(S) &
        is_at_aim_position &
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
        is_at_aim_position &
        
        position(MyV) & myTeam(MyTeam) &
        ia.edge(MyV,V,_) & 
        not ia.vertex(V, MyTeam) &
        not there_is_any_enemy_at(V) &
        
        ia.edge(MyV,MyW1,_) & ia.edge(MyW1,MyY1,_) & MyV \== MyY1 & there_is_friend_at(MyY1) &
        ia.edge(V,W1,_) & ia.edge(W1,MyY1,_) & V \== MyV & V \== MyY1 & not there_is_any_enemy_at(W1) &
        
        ia.edge(MyV,MyW2,_) & MyW2 \== MyW1 & ia.edge(MyW2,MyY2,_) & MyV \== MyY2 & MyY2 \== MyY1 & MyY2 \== W1 & MyY2 \== MyW1 & there_is_friend_at(MyY2) &
        ia.edge(V,W2,_) & W2 \== W1 & W2 \== MyY1 & W2 \== MyW1 & ia.edge(W2,MyY2,_) & V \== MyY2 & not there_is_any_enemy_at(W2).
        
        
        
/* Going to a vertex that doesn't belong to us */                               
going_to_outside_goal(Op) :- can_expand_aim_vertex & is_inside_team_region_walk & position(MyV)  & myTeam(MyTeam) & 
                           .setof(V, ia.edge(MyV,V,_) & 
                           			not ia.vertex(V, MyTeam) & 
                           			not there_is_friend_at(V) &
                           			not there_is_any_enemy_at(V), Options
                           ) &
                           .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/* Going to a vertex that has some neighbor vertex that doesn't belong to us */                            
going_to_outside_goal(Op) :- can_expand_aim_vertex & is_inside_team_region_walk & position(MyV)  & myTeam(MyTeam) & 
                           .setof(V, ia.edge(MyV,V,_) & 
                           			ia.edge(V,W,_) & 
                           			not ia.vertex(W, MyTeam) &
                           			not there_is_friend_at(V) & 
                           			not there_is_any_enemy_at(V), Options
                           ) &
                           .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
going_to_outside_goal(Op) :- can_expand_aim_vertex & is_inside_team_region_walk & position(MyV)  & myTeam(MyTeam) & 
                           .setof(V, ia.edge(MyV,V,_) & 
                           			ia.edge(V,W,_) & 
                           			not ia.vertex(W, MyTeam), Options
                           ) &
                           .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/* Going to a vertex randomly */                            
going_to_outside_goal(Op) :- can_expand_aim_vertex & is_inside_team_region_walk & position(MyV) & 
                           .setof(V, ia.edge(MyV,V,_), Options) &
                           .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                            
//TODO encontrar os vértices de borda e fazer BFS até algum deles, pegar o maior valor de vertice
                            