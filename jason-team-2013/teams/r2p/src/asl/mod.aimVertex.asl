is_goal_keep_aim_vertex :- aim_vertex_belongs_to_us(_)
						   |
						   (position(MyV) & aimVertex(MyV, _, _)).

is_goal_aim_vertex(D) :- aimVertex(D, _, _) & not is_disabled & position(MyV)  & 
								ia.edge(MyV,D,_).

is_goal_aim_vertex(D, Path) :- aimVertex(D, _, _) & not is_disabled & position(MyV)  &  
								ia.shortestPath(MyV, D, Path, Lenght) &
                                Lenght > 2.
                                
aim_vertex_belongs_to_us(V) :- aimVertex(V, _, _) & 
						    (island_belongs_to_us(V) | pivot_belongs_to_us(V)).
	
+!getAgentsOrder(Result):
	noMoreVertexToProbe
<-
	.findall(Ag, play(Ag,_,"grPivots") & friend(Ag, _, sentinel, _), ListSentinel);
	.findall(Ag, play(Ag,_,"grPivots") & friend(Ag, _, inspector, _), ListInspector);
	.findall(Ag, play(Ag,_,"grPivots") & friend(Ag, _, explorer, _), ListExplorer);
	.findall(Ag, play(Ag,_,"grPivots") & friend(Ag, _, repairer, _), ListRepairer);
	.concat(ListSentinel, ListInspector, ListRepairer, ListExplorer, Result).
	
+!getAgentsOrder(Result):
	true
<-
	.findall(Ag, play(Ag,_,"grPivots") & friend(Ag, _, sentinel, _), ListSentinel);
	.findall(Ag, play(Ag,_,"grPivots") & friend(Ag, _, inspector, _), ListInspector);
	.findall(Ag, play(Ag,_,"grPivots") & friend(Ag, _, repairer, _), ListRepairer);
	.findall(Ag, play(Ag,_,"grPivots") & friend(Ag, _, explorer, _), ListExplorer);
	.concat(ListSentinel, ListInspector, ListExplorer, ListRepairer, Result).

+!distributeAimVertices:
	pivots(ListPivots) & islands(ListIslands)
<-
	!getAgentsOrder(ListAgs);
	.abolish(allIslandVertices(_));
	+allIslandVertices([]);
	.print("#DISTRIBUTE# Distributing vertices to ", ListAgs);
	!distributeAimVertices(ListPivots, ListIslands, ListAgs).
	
+!distributeAimVertices:
	.findall(Ag, play(Ag,_,"grPivots"), ListAgs) & 
	pivots(ListPivots) & not islands(_)
<-
	+islands([]);
	!distributeAimVertices(ListPivots, [], ListAgs).
	
+!distributeAimVertices:
	.findall(Ag, play(Ag,_,"grPivots"), ListAgs) & 
	not pivots(_) & islands(ListIslands)
<-
	+pivots([]);
	!distributeAimVertices([], ListIslands, ListAgs).

	
+!distributeAimVertices(_, _, []). //There is no more agents
+!distributeAimVertices([], _, _) <-
	.print("#DISTRIBUTE# Probably the hill phase is finished. I don't have pivots anymore.");
	?hill(_).
+!distributeAimVertices([], [], ListAgs) <-
    .print("#DISTRIBUTE# There is no islands and no vertices ", ListAgs);
	.send(ListAgs, achieve, dismissAimVertex). //There is no more vertices to go
+!distributeAimVertices([pivot(V1, V2, VerticesP, Value) | TV], [], [A1, A2 | TA]) //There is no island
<-
	.print("#DISTRIBUTE# There is no islands ", V1, " ", V2);
	.send(A1, achieve, gotoPivotVertex(V1, pivot(V1, V2, VerticesP, Value)));
	.send(A2, achieve, gotoPivotVertex(V2, pivot(V1, V2, VerticesP, Value)));
	!distributeAimVertices(TV, [], TA).
+!distributeAimVertices(_, [], [A | []]) //There is no island and just one agent
<-
	.print("#DISTRIBUTE# There is no island and just one agent");
	.send(A, achieve, dismissAimVertex).
+!distributeAimVertices(_, [island(V, Vertices, Value) | _], [A | []]) //There is island and just one agent
<-
	.print("#DISTRIBUTE# There is island and just one agent ", V);
	.send(A, achieve, gotoIslandVertex(V, island(V, Vertices, Value)));
	!addIsland(Vertices);.
	
	
+!distributeAimVertices([pivot(V1, V2, VerticesP, Value) | TV], [island(VIsland, VerticesIsland, ValueIsland) | []], [A1, A2 | TA]): //There is just one island
	Value > ValueIsland //Just use pivot if the value of the pivot is greater than the value of the island
<-
	.print("#DISTRIBUTE# There is a good pivot, better than the only island ", V1, " ", V2);
	.send(A1, achieve, gotoPivotVertex(V1, pivot(V1, V2, VerticesP, Value)));
	.send(A2, achieve, gotoPivotVertex(V2, pivot(V1, V2, VerticesP, Value)));
	!distributeAimVertices(TV, [island(VIsland, VerticesIsland, ValueIsland) | []], TA).
+!distributeAimVertices([pivot(V1, V2, VerticesP, Value) | TV], [island(VIsland, VerticesIsland, ValueIsland) | []], [A1, A2 | TA]): //There is just one island
	true //Otherwise use the island
<-
	.print("#DISTRIBUTE# It's better to use the only island ", VIsland);
	.send(A1, achieve, gotoIslandVertex(VIsland, island(VIsland, VerticesIsland, ValueIsland)));
	!addIsland(VerticesIsland);
	!distributeAimVertices([pivot(V1, V2, VerticesP, Value) | TV], [], TA).
	
+!distributeAimVertices([pivot(V1, V2, VerticesP, Value) | TV], [island(VIsland1, VerticesIsland1, ValueIsland1), island(VIsland2, VerticesIsland2, ValueIsland2) | TI], [A1, A2 | TA]): //There is more islands
	Value > ValueIsland1 + ValueIsland2 //Just use pivot if the value of the pivot is greater than the value of the two islands
<-
	.print("#DISTRIBUTE# The pivot is better than two islands ", V1, " ", V2);
	.send(A1, achieve, gotoPivotVertex(V1, pivot(V1, V2, VerticesP, Value)));
	.send(A2, achieve, gotoPivotVertex(V2, pivot(V1, V2, VerticesP, Value)));
	!distributeAimVertices(TV, [island(VIsland1, VerticesIsland1, ValueIsland1), island(VIsland2, VerticesIsland2, ValueIsland2) | TI], TA).
+!distributeAimVertices([pivot(V1, V2, VerticesP, Value) | TV], [island(VIsland1, VerticesIsland1, ValueIsland1), island(VIsland2, VerticesIsland2, ValueIsland2) | TI], [A1, A2 | TA]): //There is more islands
	true //Otherwise use the island 
<-
	.print("#DISTRIBUTE# It's better to use two islands ", VIsland1, " ", VIsland2);
	.send(A1, achieve, gotoIslandVertex(VIsland1, island(VIsland1, VerticesIsland1, ValueIsland1)));
	.send(A2, achieve, gotoIslandVertex(VIsland2, island(VIsland2, VerticesIsland2, ValueIsland2)));
	!addIsland(VerticesIsland1);
	!addIsland(VerticesIsland2);
	!distributeAimVertices([pivot(V1, V2, VerticesP, Value) | TV], TI, TA).
	
+!dismissAimVertex <- //I don't have aim vertex anymore
	.print("I'm dismissed");
	.abolish(aimVertex(_,_,_)).	
	
	
+!addIsland(NewVertices):
	allIslandVertices(L)
<-
	.concat(NewVertices, L, ResultL);
	.abolish(allIslandVertices(L));
	+allIslandVertices(ResultL).
-!addIsland(NewVertices)[error(ErrorCode),error_msg(MsgError)] <-
	.print("Error occurred to add island! ", ErrorCode, " -> ", MsgError).