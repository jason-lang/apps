+!determineIslands:
	.count(play(Ag,_,"grPivots"), NumberIslands)
<-
	.print("Calculating islands");
    ia.getIslands(NumberIslands, List);
    .abolish(islands(_, _));
    +islands(List);
    .print("#ISLANDS# ", List);
    !distributeAimVertices.
    
+!gotoIslandVertex(V, Description) 
<-
	.abolish(aimVertex(_,_,_));
	+aimVertex(V, island, Description).