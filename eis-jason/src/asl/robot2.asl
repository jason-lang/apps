// Agent sample in project JasonWithEIS

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- wait; push; !!start.

+step(X) : carriagePos(C) <- .print("Step ",X,", carriage at ",C).