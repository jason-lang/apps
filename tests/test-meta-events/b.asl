/* Initial goals */

!move. // simulates robot movement
!bat.  // simulates low battery


/* Plans */

+!move <- .print(moving); .wait(200); !!move.

+!bat  <- .wait(500); +battery(low); !!bat.


+battery(low) <- !charge.

+!charge <- .print(charging); .wait(1000); .print(charged); -battery(low).

/* meta-plans */

// when goal charge is started, suspends goal move

^!charge[state(started)] <- .suspend(move).
^!charge[state(finished)] <- .resume(move).
^!charge. // I am not interested in other states

// states are: started, suspended, resumed, finished, failed
// see GoalListener API doc

