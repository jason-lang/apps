+!stopFocusArtifacts: 
	artifact(Name, IdArt)
<-
	-artifact(Name, IdArt);
	stopFocus(IdArt);
	!stopFocusArtifacts.
+!stopFocusArtifacts.
	
+!focusArtifact(Name) <-
    lookupArtifact(Name, IdArt);
	focus(IdArt);
	+artifact(Name, IdArt);
	.print("Loaded artifact ", Name).

	
	
+count(X)
   <- .print("Count is ",X).
   
-count(X)
   <- .print("NON Count is ",X).