there_is_enemy_in_island(V, VerticesIsland, ValueIsland) :-  
						    aimVertex(V, island, island(V, VerticesIsland, ValueIsland)) & 
							position(V) & myTeam(MyTeam) & .member(Vtest,VerticesIsland) &
							ia.vertex(Vtest, Team) & Team \== MyTeam.
							
island_belongs_to_us(V) :- aimVertex(V, island, island(V, VerticesIsland, ValueIsland)) & 
							myTeam(MyTeam) & 
							not (
								.member(Vtest,VerticesIsland) &
								ia.vertex(Vtest, Team) & Team \== MyTeam
							).


+!determineIslands:
	.count(play(Ag,_,"grPivots"), NumberIslands)
<-
	.print("Calculating islands");
    ia.getIslands(NumberIslands, List);
    .abolish(islands(_, _));
    +islands(List);
    .print("#ISLANDS# ", List);
    !distributeAimVertices.
    
@gotoIslandVertex[atomic]
+!gotoIslandVertex(V, Description) 
<-
	.abolish(aimVertex(_,_,_));
	+aimVertex(V, island, Description).
	
	
+!testCleanIsland:
	there_is_enemy_in_island(V, VerticesIsland, ValueIsland)
<-
	.print("There is some enemy in the island! ", V).
+!testCleanIsland:
	island_belongs_to_us(V)
<-
	.print("The island belongs to us! ", V).
+!testCleanIsland.	