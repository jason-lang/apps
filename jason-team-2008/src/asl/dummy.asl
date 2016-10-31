// Code of dummy agents 

/* 
   Perceptions
      Begin:
        gsize(Weight,Height)
        steps(MaxSteps)
        corral(UpperLeft.x,UpperLeft.y,DownRight.x,DownRight.y)
        
      Each step:
        pos(X,Y,Step)
        cow(Id,X,Y)
        apply_pos(Name,X,Y)
        

      End:
        end_of_simulation(Result)

*/

/* -- initial beliefs -- */

ag_perception_ratio(8). // ratio of perception of the agent
cow_perception_ratio(4).

/* -- useful rules */ 

// find a free random location    
random_pos(X,Y) :- 
   pos(AgX,AgY,_) &
   jia.random(RX,40)   & RX > 5 & X = (RX-20)+AgX & X > 0 &
   jia.random(RY,40,5) & RY > 5 & Y = (RY-20)+AgY &
   not jia.obstacle(X,Y) &
   not cell(X,Y,_).


/* -- initial goal */

!decide_target.


/* -- reaction to some perceptions -- */

// revise target when see first cow
+pos(_,_,_)                  // new cycle
   : goal(search) & cell(_,_,cow(_))  // I see cows and was searching
  <- !decide_target. 

// revise target each 6 steps
+pos(Step,_,_)                  // new cycle
   : Step mod 6 == 0
  <- !decide_target. 


/* -- decide a new target -- */

+!decide_target
   : not pos(_,_,_)
  <- .print("waiting my location....");
     .wait({+pos(_,_,_)});
     !decide_target.

+!decide_target                  
   : jia.cluster(C) &
     jia.herd_position(six,C,X,Y) 
  <- .print("COWS! going to ",X,",",Y); //," previous target ",TX,",",TY);
     -+goal(herd);
     -+target(X,Y).

+!decide_target                  // chose a new random pos
  <- ?random_pos(NX,NY);
     .print("New random target: ",NX,",",NY);
     -+goal(search);
     -+target(NX,NY).
  

/* -- plans to move to a destination represented in the belief target(X,Y) 
   -- (it is a kind of persistent goal)
*/

// if the target is changed, "restart" move
+target(NX,NY)
  <- .drop_desire(move);
     jia.set_target(NX,NY);
     !!move.

// I still do not know my location
+!move
    : not pos(_,_,_)
  <- .print("waiting my location....");
     .wait({+pos(_,_,_)});
     !move.

+!move
   : not target(_,_)
  <- .print("waiting my target....");
     .wait({+target(_,_)});
     !move.

+!move 
   : pos(X,Y,_) & target(X,Y)  // I am at target
  <- -+at_target;
     do(skip);
     !!move.
  
// does one step towards target  
+!move 
    : pos(X,Y,_) & 
      target(BX,BY) & 
      jia.direction(X, Y, BX, BY, D) // jia.direction finds one action D (using A*) towards the target
   <- do(D);  // this action will "block" the intention until it is sent to the simulator (in the end of the cycle)
      !!move. // continue moving
  
// in case of failure, move
-!move
   <- .current_intention(I); .println("failure in move, intention: ",I);
      !move.

+!restart 
  <- .print("*** restart ***"); 
     .drop_all_desires;
     .abolish(target(_,_));
     !decide_target.

/* -- tests -- */


+gsize(Weight,Height) <- .println("gsize  = ",Weight,",",Height).
+steps(MaxSteps)      <- .println("steps  = ",MaxSteps).
+corral(X1,Y1,X2,Y2)  <- .println("corral = ",X1,",",Y1," -- ",X2,",",Y2).

//+cell(X,Y,Type)       <- .println("cell   = ",X,",",Y," = ",Type).
+pos(X,Y,S)           <- .println("pos    = ",X,",",Y,"/",S).
