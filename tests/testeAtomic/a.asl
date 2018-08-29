!start1.
!start2.
!start3(0).

+!start1 : true <- .print(a); !start1.
+!start2 : true <- .print(b); !start2.

+!start3(0) : true <- .wait(100); !start3(1).
+!start3(C) : C < 50 <- .print(C); !start3(C+1).

@l[atomic]
+!start3(C) : C >= 50 & C < 100 <- !g(0); .print("-",C);  !start3(C+1).

+!g(10).
@gl[atomic]
+!g(X) <- .print("   :",X); !g(X+1).

+!start3(100)  <- !!start4(101). // to loose atomic

+!start4(C) : C < 150 <- .print("=",C); !start4(C+1).
+!start4(_) <- .stopMAS.
