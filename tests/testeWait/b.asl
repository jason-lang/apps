// b in project testeWait.mas2j
demo.
+demo : true <- !!g0.

+!g0 : true <- !g1; .print(fimdemo).
+!g1 : true <- .print(g1); !g2; .print(fimg1).
+!g2 : true <- .print(g2); !g3; .print(fimg2).
+!g3 : true <- .print(g3); !g4; .print(fimg3).
-!g0 : true <- .print("falha").


//+a(X) : true <- .print("rec a",X); -a(X); .print(removed).

