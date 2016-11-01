is_goal_keep_pivot_vertex :- position(MyV) & pivotVertex(MyV).

is_goal_pivot_vertex(D) :- pivotVertex(D) & not is_disabled & position(MyV)  & 
								ia.edge(MyV,D,_).

is_goal_pivot_vertex(D, Path) :- pivotVertex(D) & not is_disabled & position(MyV)  &  
								ia.shortestPath(MyV, D, Path, Lenght) &
                                Lenght > 2.

+!determinePivots:
	.count(play(Ag,_,"grPivots"), NumberPivots)
<-
	Pairs = NumberPivots div 2;
    ia.getPivots(Pairs, List);
    .abolish(pivots(_, _));
    +pivots(Pairs, List);
    .print(List);
    !distributePivots.

+!distributePivots:
	.findall(Ag, play(Ag,_,"grPivots"), ListAgs) & pivots(Pairs, ListPivots)
<-
	!distributePivots(ListPivots, ListAgs).

+!distributePivots([], []).
+!distributePivots([pivot(V1, V2) | TV], [A1, A2 | TA])
<-
	.send(A1, achieve, gotoPivotVertex(V1));
	.send(A2, achieve, gotoPivotVertex(V2));
	!distributePivots(TV, TA).
	
+!gotoPivotVertex(V) 
<-
	.abolish(pivotVertex(_));
	+pivotVertex(V).
	