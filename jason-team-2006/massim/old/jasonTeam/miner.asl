// miner agent

// take gold
/*
+pos(Step, X, Y) 
  :  cell(X, Y, gold)
  <- do(pick).

+cell(X,Y,gold) 
  : true
  <- !go(X,Y).
*/

// if I am miner 1, go to depot (just for test)
+pos(Step, X, Y) 
  :  .myName(miner1) & depot(_,DepotX, DepotY)
  <- .print("**", X, "," , Y, "->", DepotX, ",", DepotY); !go(Step,DepotX, DepotY).

// try to go up
+pos(Step, X, Y) 
  :  Y > 0 & not cell(X,Y-1,obstacle)
  <- do(up).

// try to go down
+pos(Step, X, Y) 
  :  gsize(_,W,H) & Y < H & not cell(X,Y+1,obstacle)
  <- do(down).

/*  
// try to go left
+pos(Step, X, Y) 
  :  X > 0 & not cell(X-1,Y,obstacle)
  <- do(left).

// try to go right
+pos(Step, X, Y) 
  :  gsize(_,W,H) & X < W & not cell(X+1,Y,obstacle)
  <- do(right).
*/  
  
+!go(Step,X,Y) 
  :  pos(_,X,Y)
  <- true.
+!go(Step,X,Y)
  : pos(Step,AgX,AgY)
  <- jia.getDirection(AgX, AgY, X, Y, D);
     do(D).

