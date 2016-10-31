// Agent b in project testEndGoal.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.
!g.

/* Plans */

+!start : true <- .wait(1500); .suspend(g); .print("wait 3 sec"); .wait(3000); .resume(g).

+!g <- .print("."); .wait(500); !!g.

^!g[state(suspended)] <- .print("-").
^!g[state(resumed)]   <- .print("+").

