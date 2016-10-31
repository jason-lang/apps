// Agent a in project TestJade.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start(5).

/* Plans */

+!start(0)<- .print(end). //.stopMAS.
+!start(X) : true 
   <- .print(X);
      act(a,X);
      !start(X-1).
	  
+hello[source(A)] <- .print("Received hello from ",A).
+alo[source(A)] <- .print("Received alo from ",A).

+percept(X) <- .print("Ok perception ",X).

