/*
 * Choose the vertex to go that it isn't visited by any of my friends. The vertex wasn't visited yet.
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.visitedVertex(V, _),Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF & not ia.visitedVertex(V, _),Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).

/*
 * Choose the vertex to go that I know the cost of the edge
 */
is_good_destination(Op) :- position(MyV) & maxWeight(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
is_good_destination(Op) :- position(MyV) & infinite(INF) &
                           .setof(V, ia.edge(MyV,V,W) & W \== INF, Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                           
/*
 * By this time, I don't have any option to go!
 * I choose randomly
 */
is_good_destination(Op) :- position(MyV) & 
                           .setof(V, ia.edge(MyV,V,_), Options)
                           & .length(Options, TotalOptions) & TotalOptions > 0 &
                           .nth(math.random(TotalOptions), Options, Op).
                                            	
                                            	
                                            	
                                            