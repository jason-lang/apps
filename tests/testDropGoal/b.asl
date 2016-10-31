// Agent b in project testDropGoal.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start1.
!start2.

/* Plans */

+!start1             <- .print(ini); !start1(0); .print(end).
+!start1(X) : X < 40 <- .print(X); !start1(X+1); .print("*",X).
-!start1(X)          <- .print("failure handling for start1").

+!start2 <- .wait("+!start1(20)"); .fail_goal(start1(3)).

