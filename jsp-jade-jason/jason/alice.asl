!start(0).

+!start(X) 
   <- .send(snooper,tell,hello(X));
      .print("sent ",X);
      .wait(1000);
      !start(X+1).

+!hello(M)[source(A)] <- .print("I received a hello ",M," from ",A).

