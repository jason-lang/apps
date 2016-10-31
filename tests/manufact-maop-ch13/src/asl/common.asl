/* auxiliary plans for Cartago */

+!in_ora4mas <-
      .wait(300);
      joinWorkspace("ora4mas",_);
	  +in_ora4mas.

// try to find a particular artifact and then focus on it
+!discover_art(ToolName) <-
      lookupArtifact(ToolName,ToolId);
      focus(ToolId).
// keep trying until the artifact is found
-!discover_art(ToolName) <-
      .wait(100);
      !discover_art(ToolName).


/* auxiliary rules and plans for Moise */

// agents A playing role R in group G
play(A,R,G) :-
   players(LP)[artifact_name(_,G)] & .member(plays(A,R),LP).
// agents A committed to mission M in scheme S
commitment(A,M,S) :-
   players(LP)[artifact_name(_,S)] & .member(plays(A,M),LP).

// keep focused on schemes that my groups are responsible for
+schemes(L) <-
      for ( .member(S,L) ) {
         lookupArtifact(S,ArtId);
         focus(ArtId)
      }.


/* Organisational Plans Required by all agents */

// plans to handle obligations
// obligation to commit to a mission
+obligation(Ag,Norm,committed(Ag,Mission,Scheme),Deadline)
    : .my_name(Ag)
   <- .print("I am obliged to commit to ",Mission," on ",Scheme,"... doing so");
      lookupArtifact(Scheme,Id); 
      commitMission(Mission)[artifact_id(Id)]. 
// obligation to achieve a goal      
+obligation(Ag,Norm,achieved(Scheme,Goal,Ag),Deadline)
    : .my_name(Ag)
   <- .print("I am obliged to achieve goal ",Goal);
      !Goal[scheme(Scheme)];
      lookupArtifact(Scheme,Id); 
      goalAchieved(Goal)[artifact_id(Id)].
// an unknown type of obligation was received
+obligation(Ag,Norm,What,DeadLine) :
   .my_name(Ag) <-
      .print("I am obliged to ",What,", but I don't know what to do!").
