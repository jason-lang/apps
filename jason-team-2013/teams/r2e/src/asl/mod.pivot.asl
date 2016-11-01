+!determinePivots:
	.count(play(Ag,_,"grPivots"), NumberPivots)
<-
	Pairs = NumberPivots div 2;
    ia.getPivots(Pairs, List);
    .abolish(pivots(_, _));
    +pivots(List);
    .print("#PIVOTS# ", List);
    !distributeAimVertices.
	
+!gotoPivotVertex(V, Description) 
<-
	.abolish(aimVertex(_,_,_));
	+aimVertex(V, pivot, Description).
	