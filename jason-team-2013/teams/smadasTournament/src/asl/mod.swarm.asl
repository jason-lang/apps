
is_free_to_walk :- .my_name(MyName) & 
					(
					 friend(MyName, _, explorer, _) & noMoreVertexToProbe
						|
					 not friend(MyName, _, explorer, _)
					).

/* #################################################################
 * This rule test if an agent is inside good area and try to go out
 * #################################################################
 */ 
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & at_the_hill_no_points & is_inside_team_region_walk &
                           position(MyV) & myTeam(MyTeam) &
                           .setof(V, 
                                ia.edge(MyV,V,_) &
                                not there_is_enemy_at(V) &
                                not ia.vertex(V, MyTeam) &
                                .member(V, Neighborhood) &
                                not lastPosition(V)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & at_the_hill_no_points & is_inside_team_region_walk &
                           position(MyV) & myTeam(MyTeam) & 
                           .setof(V, 
                                ia.edge(MyV,V,_) &
                                ia.edge(V,W,_) &
                                MyV \== W &
                                not there_is_enemy_at(V) &
                                not there_is_friend_at(V) &
                                not ia.vertex(W, MyTeam) &
                                .member(V, Neighborhood) &
                                not lastPosition(V)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & at_the_hill_no_points & is_inside_team_region_walk &
                           position(MyV) & myTeam(MyTeam) & 
                           .setof(V, 
                                ia.edge(MyV,V,_) &
                                ia.edge(V,W,_) &
                                MyV \== W &
                                not there_is_enemy_at(V) &
                                not there_is_friend_at(V) &
                                not ia.vertex(W, MyTeam) &
                                .member(V, Neighborhood)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & at_the_hill_no_points & is_inside_team_region_walk &
                           position(MyV) & myTeam(MyTeam) & 
                           .setof(V, 
                                ia.edge(MyV,V,_) &
                                ia.edge(V,W,_) &
                                MyV \== W &
                                not there_is_enemy_at(V) &
                                not ia.vertex(W, MyTeam) &
                                .member(V, Neighborhood) &
                                not lastPosition(V)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
                           
/* #################################################################
 * These rules are used when an agent are inside the good area and trying to find a good position
 * #################################################################
 */
  //############# Check enemy and friend there
/*
 * Choose the vertex to go that it isn't visited by any of my friends. The vertex wasn't visited yet.
 */
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & at_the_hill_no_points & position(MyV) & myTeam(MyTeam) &
                           .setof(V, 
                                ia.edge(MyV,V,_) & 
                                not there_is_enemy_at(V) &
                                not there_is_friend_at(V) &
                                not lastPosition(V) &
                                ia.edge(V,Y,_) &
                                MyV \== Y &
                                ia.edge(Y,M,_) &
                                V \== M &
                                ia.vertex(M, MyTeam) &
                                not there_is_friend_at(Y) &
                                there_is_friend_at(M) &
                                .member(V, Neighborhood)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & at_the_hill_no_points & position(MyV) & myTeam(MyTeam) &
                           .setof(V, 
                                ia.edge(MyV,V,_) & 
                                not there_is_enemy_at(V) &
                                not there_is_friend_at(V) &
                                not lastPosition(V) &
                                ia.edge(V,Y,_) &
                                MyV \== Y &
                                ia.vertex(Y, MyTeam) & 
                                not there_is_friend_at(Y) &
                                .member(V, Neighborhood)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
is_good_destination_hill(Op) :-  hill(Neighborhood) & is_free_to_walk & at_the_hill_no_points & position(MyV) & myTeam(MyTeam) &
                           .setof(V, 
                                ia.edge(MyV,V,_) & 
                                not there_is_enemy_at(V) &
                                not there_is_friend_at(V) &
                                not lastPosition(V) &
                                ia.edge(V,Y,_) &
                                MyV \== Y &
                                ia.edge(Y,M,_) &
                                V \== M &
                                ia.vertex(M, MyTeam) &
                                .member(V, Neighborhood)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & at_the_hill_no_points & position(MyV) & myTeam(MyTeam) & 
                           .setof(V, 
                                ia.edge(MyV,V,_) & 
                                not there_is_enemy_at(V) &
                                not there_is_friend_at(V) &
                                not lastPosition(V) &
                                ia.edge(V,Y,_) &
                                MyV \== Y &
                                ia.vertex(Y, MyTeam) & 
                                .member(V, Neighborhood)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
/* #################################################################
 * These rules are used when an agent are inside the good area (outside)
 * #################################################################
 */
 //############# Check enemy and friend there
/*
 * Choose the vertex to go that it isn't visited by any of my friends. The vertex wasn't visited yet.
 */
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & position(MyV) & infinite(INF) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF & 
                                not ia.visitedVertex(V, _) &
                                not there_is_enemy_at(V) &
                                not there_is_friend_at(V) & 
                                .member(V, Neighborhood) &
                                not lastPosition(V)
                                ,Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & position(MyV) & infinite(INF) &
                           .setof(V, 
                                ia.edge(MyV,V,W) & W \== INF &
                                not there_is_enemy_at(V) &
                                not there_is_friend_at(V) &
                                .member(V, Neighborhood) & 
                                not lastPosition(V)
                                , Options
                           )
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

//############# Do not check enemy and friend
/*
 * Choose the vertex to go that it isn't visited by any of my friends. The vertex wasn't visited yet.
 */
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.visitedVertex(V, _) & .member(V, Neighborhood) & not lastPosition(V),Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * Choose the vertex to go that I know the cost of the edge
 */
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & .member(V, Neighborhood) & not lastPosition(V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
/*
 * By this time, I don't have any option to go!
 * I choose randomly
 */
is_good_destination_hill(Op) :- hill(Neighborhood) & is_free_to_walk & position(MyV) &
                           .setof(V, ia.edge(MyV,V,_) & .member(V, Neighborhood) & not lastPosition(V), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
                           
                           
