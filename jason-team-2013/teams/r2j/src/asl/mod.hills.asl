is_goal_hill_vertex(D) :- hill(Neighborhood) & not at_the_hill & not is_disabled & position(MyV) & 
								.member(D, Neighborhood) &
								ia.edge(MyV,D,_).

is_goal_hill_vertex(D, Path) :- hill(Neighborhood) & not at_the_hill & not is_disabled & position(MyV) &
  								ia.shortestPathDijkstraCompleteTwo(MyV, Neighborhood, D, Path, Lenght) &
                                Lenght > 2.
                                
//I'm at the hill if I see some vertex of the hill and I'm in some zone or if I'm at some vertex of the hill
at_the_hill :- hill(Neighborhood) & position(MyV) & myTeam(MyTeam) &
				(
					.member(MyV, Neighborhood) &
					ia.edge(MyV,V,_) &
					.member(V, Neighborhood) &
					ia.vertex(V, MyTeam) &
					zoneScore(ZoneScore) & ZoneScore > 10 
				|
					.member(MyV, Neighborhood)
				).
				
at_the_hill_no_points :- hill(Neighborhood) & position(MyV) & myTeam(MyTeam) & .member(MyV, Neighborhood).
				
+!determineHills:
	true
<-
	.print("Calculating hills");
	!buildBestCoverage(BestVertex); //Calculate the first hill and return the vertex to ignore
	!buildBestCoverageTwo(BestVertex). //Use the vertex to ignore to calculate the second hill

+!buildBestCoverage(BestVertex):    
    S < 30
<-
    .print("#HILL# Calculing the best coverage...");
    ia.bestCoverage(1, BestVertex, BestValue);
    ia.neighborhood(BestVertex, 1, Neighborhood);
    .print("#HILL# Result was... BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !callGroupToHill(Neighborhood, "grAlpha").
     
+!buildBestCoverage(BestVertex):   
    true
<-
    .print("#HILL# Calculing the best coverage...");
    ia.bestCoverage(2, BestVertex, BestValue);
    ia.neighborhood(BestVertex, 2, Neighborhood);
    .print("#HILL# Result was... BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !callGroupToHill(Neighborhood, "grAlpha").
   
+!buildBestCoverageTwo(BestVertexCurrent):  
    S < 30
<-
    .print("#HILL# TWO Calculing the best coverage... Ignoring ", BestVertexCurrent);
    ia.bestCoverageIgnoringVertex(1, BestVertexCurrent, BestVertex, BestValue);
    ia.neighborhood(BestVertex, 1, Neighborhood);
    .print("#HILL# TWO Result was... BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !callGroupToHill(Neighborhood, "grBeta").
     

+!buildBestCoverageTwo(BestVertexCurrent):  
    true
<- 
    .print("#HILL# TWO Calculing the best coverage... Ignoring ", BestVertexCurrent);
    ia.bestCoverageIgnoringVertex(2, BestVertexCurrent, BestVertex, BestValue);
    ia.neighborhood(BestVertex, 2, Neighborhood);
    .print("#HILL# TWO Result was... BestVertex: ", BestVertex, " BestValue: ", BestValue, " Neighborhood: ", Neighborhood);
    !callGroupToHill(Neighborhood, "grBeta").
    
+!callGroupToHill(Neighborhood, Group):
	.setof(Ag, play(Ag,_,Group), SetAgs)
 <-	
 	.print("#HILL# Calling group ", Group, " to ", Neighborhood);
	.send(SetAgs, achieve, gotoHill(Neighborhood)).

@gotoHill[atomic]
+!gotoHill(Neighborhood)
<-
	.abolish(hill(_));
	+hill(Neighborhood).
	
+!dismissHill <- //I don't need to be in the hills anymore
	.print("I'm dismissed of hill");
	.abolish(hill(_)).	
	