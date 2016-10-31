!start.
!test.

+!start  <- .print("hello world."); .wait(100); !!start.
+!test   <- .wait(300); !do; .wait(300); !ask; .wait(300); !wait.

@l1[atomic] +!do   <- .print("doing a, nothing else must be done meanwhile"); a.
@l2[atomic] +!ask  <- .print("asking, nothing else must be done meanwhile"); .send(b,askOne,vl(X),A); .print("Ans:",A).
@l3[atomic] +!wait <- .print("waiting, nothing else must be done meanwhile"); .wait(2000); .print("end wait").


