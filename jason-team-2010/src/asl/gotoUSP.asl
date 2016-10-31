// Agent gotoUSP in project jason-team-2010



random_pos(X,Y) :- 
    pos(AgX,AgY,_) &
    jia.random(RX,20) &
    jia.random(RY,20) &
    X = (RX-10)+AgX &
    Y = (RY-10)+AgY &
    not jia.obstacle(X,Y) &
    not jia.fence(X,Y) &
    not jia.corral(X,Y).

+target_other(Id,X,Y)
<-  .print("Agent ",Id, " needs to go to (",X,",",Y,")");
jia.set_target_others(Id,X,Y).

+target(NX,NY)
: pos(MyX,MyY,_) //&
 //.my_name(Me) &
 //agent_id(Me,MyId)
  <- jia.set_target(NX,NY);
    // .send(usp1,tell,target_other(MyId,MyX,MyY));
     -at_target;
     jia.dist(MyX,MyY,NX,NY,Dist);
     .print("[gotoUSP.asl] Adding/Changing the target to (",NX,",",NY,")! distance: ", Dist);
     .drop_desire(move);
     !!move.
     
+!move 
   : target(X,Y) & jia.obstacle(X,Y)  // the target is an obstacle! 
  <- .print("[goto.asl] My target ", X, ",", Y, " is an obstacle, ignoring target!");
     -+at_target;
     do(skip);
     !!move.
     
// does one step towards target  
+!move 
   : pos(X,Y,_) & 
     target(BX,BY) & 
     //fence_obstacle(FO) &
     jia.direction(X, Y, BX, BY, D, fence)  // jia.direction finds one action D (using A*) towards the target 
  <-.print("[gotoUSP.asl] move:",D);
  	 do(D);  // this action will "block" the intention until it is sent to the simulator (in the end of the cycle)
     !!move. // continue moving

+!move. 


-!move
  <- .current_intention(I);
     .println("[goto.asl] failure in moving; intention was: ",I);
     !!move.

     
// set fence as obstacle for N cycles
+!fence_as_obstacle(N) : N <= 0
  <- -+fence_obstacle(no).
   
+!fence_as_obstacle(N) : N > 0
  <- -+fence_obstacle(fences);
     .wait( { +pos(_,_,_) } );
     !!fence_as_obstacle(N-1).
       
-!fence_as_obstacle(_) 
  <- -+fence_obstacle(no).
  
  
+!update_target(X,Y)
  <- -+target(X,Y).
  
  
+!find_closest(Agents, pos(FX,FY), NearAg) // find the agent near to pos(X,Y)
  <- .my_name(Me);
     .findall(d(D,Ag),
              .member(Ag,Agents) & (ally_pos(Ag,AgX,AgY) | Ag == Me & pos(AgX,AgY,_)) & jia.path_length(FX,FY,AgX,AgY,D),
			  Distances);
	 .min(Distances,d(_,NearAg)).
