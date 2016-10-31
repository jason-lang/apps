// Agent rotator in project manufacture.mas2j

{ include("common.asl") }

/* Initial beliefs and rules */

// rule to check if we have two concurrent orders (2 Moise schemes)
two_orders :- schemes(L) & .length(L)==2.

// only one order so far
one_order :- schemes(L) & .length(L)==1.

/* Initial goals */

!start.

/* Plans */

+!start <-
      !in_ora4mas;
      lookupArtifact("assembly_cell", GroupId);
      focus(GroupId);
      adoptRole("rotator")[artifact_id(GroupId)];
      !discover_art("table").


// first organisational goal of the rotator

// avoid conflicts when 2 orders are simultaneously waiting for empty jigs
+!wait_for_empty_jig[scheme(S1)] :
   .desire(wait_for_empty_jib[scheme(S2)]) & S1\==S2 <-
      .print("Hmmmmmm... Scheme ", S2, "already requested an empty jig; ", S1, "will have to wait");
      .wait(500);
	  !wait_for_empty_jig[scheme(S1)].

// already got an empty jig
+!wait_for_empty_jig[scheme(S)] :
   jig_loader("empty") <-
      reserve_jig(S). // make sure another order doesn't get it too

// will have to wait
+!wait_for_empty_jig[scheme(S)] <-
	  .print("... waiting for empty jig ... ");
      .wait({+jig_loader("empty")});
      reserve_jig(S);
      // if there are pending requests to rotate the table
	  if (.desire(table_rotated[scheme(S)])) {
         // might need reconsidering which plan to use
         .print("reconsidering some intentions to rotate table...");
	     .drop_desire(table_rotated[scheme(S)]);
		 !!table_rotated[scheme(S)];
	  }.
/*-!wait_for_empty_jig <-
      .print("Hmmmmmmm... problem here???");
      !wait_for_empty_jig.   // insist
*/
// second organisational goal: handling requests to rotate

// Only 1 assembling task, rotate whenever asked
+!table_rotated[scheme(S1)]
  :  one_order
  <- table_rotated;
     .print("Achieving table_rotated - Scheme ", S1).

// Let it turn if another job needs it and we are waiting for an empty jig
+!table_rotated[scheme(S1)] :
   two_orders & .desire(wait_for_empty_jig) & not jig_loader("empty") <-
      table_rotated;
	  .print("Table being rotated for ", S1, " and was waiting for EMPTY JIG!").

// If there are 2 concurrent assembling tasks, wait for both
// to want to rotate before actually rotating

// This is actually the second request to rotate
@tr[atomic] // both goals need to be considered achieved simultaneously
+!table_rotated[scheme(S1)]
  :  two_orders & .desire(table_rotated[scheme(S2)]) & S1\==S2
  <- table_rotated; // one rotation achieves both requests
  	 .print("Achieving table_rotated - Schemes ", S1, " and ", S2);
	 .succeed_goal(table_rotated[scheme(S2)]).

// The first attempt just waits for some time until the 2nd requests releases both
+!table_rotated[scheme(S)]
  :  two_orders
  <- .wait(1000); // wait a bit 
     .print("TIMED OUT: trying to rotate table again for scheme ", S);
	 !table_rotated[scheme(S)]. // try again

// just because Moise doesn't allow 2 goals with the same name
+!R[scheme(S)] <- !table_rotated[scheme(S)].

// just to help checking if all is working
+B[artifact_name(AId,"table")] <- .print("######",B).

