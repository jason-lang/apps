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
	+artifact(Name, IdArt).

	
	
	