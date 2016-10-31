// This agent acts on the two robots 
// a special action is used to indicate
// the entity where to act on
//              ae(<action>, "<entity>")

/* Initial goals */

!start1.
!start2.

/* Plans */

+!start1 : true <- ae(push,"robot1"); !!start1.                    // act on entity robot1
+!start2 : true <- ae(wait,"robot2"); ae(push,"robot2"); !!start2. // act on entity robot2

+step(X) : carriagePos(C) <- .print("Step ",X,", carriage at ",C). // print out perception
