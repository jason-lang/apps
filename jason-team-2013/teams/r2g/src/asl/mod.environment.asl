+!stopFocusArtifacts: 
	.findall(artifact(NameArt, IdArt), artifact(NameArt, IdArt), ListArt)
<-
    for (.member(artifact(NameArt, IdArt), ListArt)) {
    	stopFocus(IdArt);
    	-artifact(NameArt, IdArt);
    }.
    
+!stopFocusArtifact(NameArt, IdArt): 
	true
<-
	stopFocus(IdArt);
	-artifact(NameArt, IdArt);
	.print("Stopped focus artifact ", NameArt, " ", IdArt).
	
+!focusArtifact(Name) <-
    lookupArtifact(Name, IdArt);
	focus(IdArt);
	+artifact(Name, IdArt);
	.print("Loaded artifact ", Name, " ", IdArt).
	
+!focusArtifact(Name, IdArt) <-
	+artifact(Name, IdArt);
	.print("Loaded artifact ", Name, " ", IdArt).
	
+count(X)
   <- .print("Count is ",X).
   
-count(X)
   <- .print("NON Count is ",X).