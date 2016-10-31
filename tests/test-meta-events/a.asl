!start.

+!start <- 
   !g; 
   !!s; 
   .wait(300);
   +b;
   .wait(3000);
   .suspend(s); .wait(2000); .resume(s); .wait(300); .succeed_goal(s); .print(endstart).


+!g <- .fail; .print(endg).
-!g <- .print(ok).

+!s <- .print(starts); .wait({+b}); paint; !s2; .print(ends).
+!s2 <- .print(s); .wait(100); !s2.

^!s[state(S)[reason(M)]] <- .print("Goal ",s," changed to state ", S, " due to ",M).
^!s[state(S)] <- .print("Goal ",s," changed to state ", S).
