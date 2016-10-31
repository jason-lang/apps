// Agent a in project testEndGoal.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start <- !g.
*!start <- .print(endstart). // *! in the same int stack: YES. If *! fails, should fail ! : NO.
-!start <- .print(falhastart).

+!g <- .print(g). //; !ooo.
*!g <- .print(a1); .print(aa); !ooo; .print(endg).
-!g <- .current_intention(X); .print(X); .print(falhaG).

//+!ooo <- .print(b). //.fail.

