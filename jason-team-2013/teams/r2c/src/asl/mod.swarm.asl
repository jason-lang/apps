+!setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood):
    true
<-
    .abolish(bestVertexArea(_));
    +bestVertexArea(BestVertex);
    .print("## NEW BEST COVERAGE received! Vertex: ", BestVertex, " Value: ", BestValue, " Neighborhood: ", Neighborhood);
    !ajustAllowedDistance.
    
+!ajustAllowedDistance:
    step(S) & S < 50
<-
    !setAllowedDistance(1,0).
    
+!ajustAllowedDistance:
    step(S) & S < 8000
<-
    !setAllowedDistance(2,0).
    
+!ajustAllowedDistance:
    true
<-
    !setAllowedDistance(3,1).
    
+!setAllowedDistance(DistanceOutside, DistanceInside):
    not allowedDistance(DistanceOutside,DistanceInside)
<-
    .print("New allowed distance setted to ", DistanceOutside, " and ", DistanceInside);
    .abolish(allowedDistance(_,_));
    +allowedDistance(DistanceOutside,DistanceInside);
    !calculeAllowedArea(DistanceOutside,DistanceInside).
+!setAllowedDistance(DistanceOutside, DistanceInside).

+!calculeAllowedArea(DistanceOutside,DistanceInside):
    bestVertexArea(D)
<-
    ia.walkAreaSwarm(D, DistanceOutside, DistanceInside, NeighborhoodOutside, NeighborhoodInside);
    .print("SWARM WALKING INSIDE. I can walk inside of (border) ", NeighborhoodOutside, " or inside of  ", NeighborhoodInside);
    .abolish(allowedArea(_, _));
    +allowedArea(NeighborhoodOutside, NeighborhoodInside).
+!calculeAllowedArea(DistanceOutside,DistanceInside).
-!calculeAllowedArea(DistanceOutside,DistanceInside): 
    true 
<- 
    .print("I do not know any vertex from the best area!").

