+edges(E): true <-
	.send(coach, achieve, setEdges(E));
    +edges(E);
    .print("Edges ", E).
    
+vertices(V): true <-
	.send(coach, achieve, setVertices(V));
    +vertices(V);
    .print("Vertices ", V).
    
+steps(S): true <-
	.send(coach, achieve, setSteps(S));
    +steps(S);
    .print("Steps ", S).
    
+simStart:
    true
<-
    .print("Contest started!").
    