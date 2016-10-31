
!go.

+!go
   :  pos(X,Y) &
      jia.near_least_visited(X,Y,ToX,ToY)
   <- //.print("From ",X,",",Y," to ",ToX,",",ToY);
      !pos(ToX,ToY);
      !!go.
+!go 
   <- !go.
   
+!pos(X,Y) : pos(X,Y) <- .print("I've reached ",X,"x",Y).
+!pos(X,Y) : not pos(X,Y)
  <- !next_step(X,Y);
     !pos(X,Y).

+!next_step(X,Y)
   :  pos(AgX,AgY)
   <- jia.get_direction(AgX, AgY, X, Y, D);
      do(D).
+!next_step(X,Y) : not pos(_,_) // I still do not know my position
   <- !next_step(X,Y).
-!next_step(X,Y) : true  // failure handling -> start again!
   <- .print("Failed next_step to ", X,"x",Y," fixing and trying again!");
      !next_step(X,Y).

