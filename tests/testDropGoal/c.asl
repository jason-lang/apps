!start1.
!start2.

+!start1    <- .print(ini); !start1(a); .print(end).
+!start1(a) <- .wait(10000); .print(error).
+!start2    <- .wait(1000); .succeed_goal(start1(a)).

