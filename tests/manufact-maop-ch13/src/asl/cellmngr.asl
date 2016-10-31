// Agent cellmngr in project manufacture.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */
@pst[atomic]
+!start
 <- // create the organisation
    createWorkspace("ora4mas");
    joinWorkspace("ora4mas",_);
    makeArtifact("assembly_cell","ora4mas.nopl.GroupBoard",["src/manufacture-os.xml", assembly_cell_group, false, true ],GrArtId);
    focus(GrArtId);
    // create artifact simulating the rotating table, rotator will focus on it
	makeArtifact("table", "rotTable", [], RTArtId);
	// simulating the arriving orders for this manufacturing unit
	makeArtifact("orders", "inTray", [], OrdArtId);
	focus(OrdArtId).

// each order generates an instance of the Manufacture scheme	
@op1[atomic] // needs to be an atomic operation: changing the no. of schemes
+order(N)
  :  formationStatus(ok)[artifact_id(GrArtId)]
     & schemes(L) & .length(L)<=1  // no more than 1 order already under way
  <- // wait until empty jig is correctly positioned at loader robor
     .concat("order", N, SchemeName);
     makeArtifact(SchemeName, "ora4mas.nopl.SchemeBoard",["src/manufacture-os.xml", manufacture_schm, false, true], SchArtId);
     focus(SchArtId);
     addScheme(SchemeName)[artifact_id(GrArtId)].
+order(N)
  :  not formationStatus(ok)[artifact_id(GrArtId)]
  <- .print("Ignoring Order ", N, ": not ready yet.").
+order(N)
  <- .print("Ignoring Order ", N, ": too busy.").


// remove scheme artifact created to manage an order that is now complete
@pgs[atomic]
+goalState(SchemeName,manufacture_ABC,_,_,satisfied)[artifact_id(AId)]
  <- destroy[artifact_id(AId)];
     disposeArtifact(AId);
     .print("Finished: ", SchemeName,". One more piece assembled!!!!!!!!!!!!!!!!!!!!").

