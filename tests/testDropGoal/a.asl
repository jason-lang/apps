// Agent a in project testDropGoal.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start1.
!start2.

/* Plans */

+!start1    <- .print(ini); !start1(0); .print(end).
+!start1(X) <- .print(X); !start1(X+1); .print("*",X).

+!start2 <- .wait("+!start1(20)"); .succeed_goal(start1(3)).

