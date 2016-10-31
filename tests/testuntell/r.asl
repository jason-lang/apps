// r in project testuntell.mas2j
+a(X) : true <- .print(X). //; !!do(1); !!undo(100); !doPrint.
+!do(X) : X < 100 <- .print(do);   .wait("+!undo(_)",1000); !!do(X+1).

+!undo(X) : X > 0 <- .print(undo); .wait("+!do(_)",2000);   !!undo(X-1).

+!doPrint : .intend(do(1)) <- .print(a).
+!doPrint : true <- .print(b).

{ include("r-inc.asl") }

