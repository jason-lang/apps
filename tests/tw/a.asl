// Agent a in project tw.mas2j

/* Initial beliefs and rules */
d(i).

/* Initial goals */

!start.
!test.

/* Plans */

+!start  <- X=10+20; .print(a); !start.

+!test 
   <- .wait(200);
      .suspend(start);        .print("------");
	  !testInt;
	  .wait(200);             .print("******");
	  .resume(start);      
	  .wait(200);
	  .drop_intention(start); .print(".............").
	  
+!testInt : .intend(start) & .suspended(start,R) <- .print(ok,R).
+!testInt <- .print(nok).

