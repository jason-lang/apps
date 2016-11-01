there_is_enemy_in_pivot(V1, V2, VerticesPivot, ValuePivot) :-  aimVertex(V, pivot, pivot(V1, V2, VerticesPivot, ValuePivot)) & 
												position(V) & myTeam(MyTeam) & .member(Vtest,VerticesPivot) &
												ia.vertex(Vtest, Team) & Team \== MyTeam.
												
pivot_belongs_to_us(V) :- aimVertex(V, pivot, pivot(V1, V2, VerticesPivot, ValuePivot)) & 
							myTeam(MyTeam) & 
							not (
								.member(Vtest,VerticesPivot) &
								ia.vertex(Vtest, Team) & Team \== MyTeam
							).

+!determinePivots:
	.count(play(Ag,_,"grPivots"), NumberPivots) & allIslandVertices(LIgnore)
<-
	Pairs = NumberPivots div 2;
    ia.getPivotsIgnoringVertices(Pairs, LIgnore, List);
    .abolish(pivots(_, _));
    +pivots(List);
    .print("#PIVOTS IGNORING# ", List, " Ignored ", LIgnore);
    !distributeAimVertices.
    
+!determinePivots:
	.count(play(Ag,_,"grPivots"), NumberPivots)
<-
	Pairs = NumberPivots div 2;
    ia.getPivots(Pairs, List);
    .abolish(pivots(_, _));
    +pivots(List);
    .print("#PIVOTS# ", List);
    !distributeAimVertices.
	
@gotoPivotVertex[atomic]
+!gotoPivotVertex(V, Description) 
<-
	.abolish(aimVertex(_,_,_));
	+aimVertex(V, pivot, Description).
	
+!testCleanPivot:
	there_is_enemy_in_pivot(V1, V2, VerticesPivot, ValuePivot)
<-
	.print("There is some enemy in the pivot! ", V1).
+!testCleanPivot:
	pivot_belongs_to_us(V)
<-
	.print("The pivot belongs to us! ", V).
+!testCleanPivot.