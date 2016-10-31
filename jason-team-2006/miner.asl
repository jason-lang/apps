// miner agent

lastDir(null).
free.

+gsize(S,W,H) : true <- .send(leader,tell,gsize(S,W,H)); !sendInitPos(S).
+!sendInitPos(S) : pos(X,Y)
  <- .send(leader,tell,myInitPos(S,X,Y)).
+!sendInitPos(S) : not pos(_,_)
  <- .wait("+pos(X,Y)", 500);
     !!sendInitPos(S).

/* plans for wandering in my quadrant when I'm free */

+free : lastChecked(XC,YC) & goingTo(XG,YG) <- !around(XC,YC); !around(XG,YG).
+free : myQuad(X1,Y1,X2,Y2) <- !around(X1,Y1).
+free : free <- !waitForQuad.
@pwfq[atomic]
+!waitForQuad : free & myQuad(_,_,_,_) <- -free; +free.
+!waitForQuad : free     <- .wait("+myQuad(X1,Y1,X2,Y2)", 500); !!waitForQuad.
+!waitForQuad : not free <- .print("No longer free while waiting for myQuad.").

+around(X1,Y1) : myQuad(X1,Y1,X2,Y2) & free
  <- .print("in Q1 to ",X2,"x",Y1); 
     -around(X1,Y1); !around(X2,Y1).

+around(X2,Y2) : myQuad(X1,Y1,X2,Y2) & free 
  <- .print("in Q4 to ",X1,"x",Y1); 
     -around(X2,Y2); !around(X1,Y1).

+around(X2,Y) : myQuad(X1,Y1,X2,Y2) & free  
  <- !calcNewY(Y,Y2,YF);
     .print("in Q2 to ",X1,"x",YF);
     -around(X2,Y); !around(X1,YF).

+around(X1,Y) : myQuad(X1,Y1,X2,Y2) & free  
  <- !calcNewY(Y,Y2,YF);
     .print("in Q3 to ", X2, "x", YF); 
     -around(X1,Y); !around(X2,YF).

// the last "around" was not any Q above
+around(X,Y) : myQuad(X1,Y1,X2,Y2) & free & Y <= Y2 & Y >= Y1  
  <- .print("in no Q, going to X1");
     -around(X,Y); !around(X1,Y).
+around(X,Y) : myQuad(X1,Y1,X2,Y2) & free & X <= X2 & X >= X1  
  <- .print("in no Q, going to Y1");
     -around(X,Y); !around(X,Y1).

+around(X,Y) : myQuad(X1,Y1,X2,Y2)
  <- .print("It should never happen!!!!!! - go home");
     -around(X,Y); !around(X1,Y1).

+!calcNewY(Y,Y2,Y2) : Y+3 > Y2 <- true.
+!calcNewY(Y,Y2,YF) : true <- YF = Y+3.


// BCG!
+!around(X,Y) : pos(AgX,AgY) & jia.neighbour(AgX,AgY,X,Y) <- +around(X,Y).
// o plano abaixo (com skip)
// causou varios problemas, principalmente qdo uma vez da skip, segue
// ignorando tudo dai a frente
//@pa[atomic]
//+!around(X,Y) : lastDir(skip) <- -lastDir(skip); +around(X,Y).
+!around(X,Y) : not around(X,Y)
  <- !next_step(X,Y);
     !!around(X,Y).
+!around(X,Y) : true <- !!around(X,Y).

+!next_step(X,Y)
  :  pos(AgX,AgY)
  <- jia.getDirection(AgX, AgY, X, Y, D);
     .print("from ",AgX,"x",AgY," to ", X,"x",Y," -> ",D);
     !update(lastDir(D));
     do(D).
+!next_step(X,Y) : not pos(_,_) // i still do not know my position
  <- !next_step(X,Y).
-!next_step(X,Y) : true // not lastDir(fail)
  <- .print("Failed next_step to ", X,"x",Y," fixing and trying again!");
     !update(lastDir(null));
     !next_step(X,Y).


/* Gold-searching Plans */

// I perceived unknown gold and I am free, handle it
@pcell[atomic] // atomic: so as not to handle another event until handle gold is carrying on
+cell(X,Y,gold) 
  :  not gold(X,Y) & free 
  <- -free;
     .print("Gold perceived: ",gold(X,Y));
     +gold(X,Y);
     !init_handle(gold(X,Y)).
     
// if i see gold and are not free but also not carrying gold yet
// (i'm probably going towards one), abort handle(gold) and catch this one that is near
@pcell2[atomic]
+cell(X,Y,gold)
  :  not gold(X,Y) & not free & not carrying_gold & .desire(init_handle(gold(XO,YO)))
  <- .dropDesire(init_handle(gold(XO,YO)));
     .dropIntention(init_handle(gold(XO,YO)));
     .print("Giving up ",gold(XO,YO), " to handle ",gold(X,Y)," that I am seeing!");
     .broadcast(tell,gold(XO,YO));
     +gold(X,Y).
@pcell3[atomic]
+cell(X,Y,gold)
  :  not gold(X,Y) & not free & not carrying_gold & .desire(handle(gold(XO,YO)))
  <- .dropDesire(handle(gold(XO,YO)));
     .dropIntention(handle(gold(XO,YO)));
     .print("Giving up ",gold(XO,YO), " to handle ",gold(X,Y));
     .broadcast(tell,gold(XO,YO));
     +gold(X,Y).

// I am not free, just add gold belief and announce to others
+cell(X,Y,gold) 
  :  not gold(X,Y) 
  <- +gold(X,Y);
     .print("Announcing ",gold(X,Y)," to others");
     .broadcast(tell,gold(X,Y)). 
     
// someone else sent me gold location
+gold(X1,Y1)[source(A)] : A \== self & free & pos(X2,Y2)
  <- jia.dist(X1,Y1,X2,Y2,D);
     .send(leader,tell,bidFor(gold(X1,Y1),D)).
// if I announced the gold location, it's because I can't go after it
+gold(X1,Y1)[source(A)] : A \== self
  <- .send(leader,tell,bidFor(gold(X1,Y1),1000)).

@palloc1[atomic]
+allocatedTo(Gold,Ag)[source(leader)] 
  :  .myName(Ag) & free // I am still free
  <- -free;
     .print("Gold ",Gold," allocated to ",Ag);
     !init_handle(Gold).

@palloc2[atomic]
+allocatedTo(Gold,Ag)[source(leader)] 
  :  .myName(Ag) & not free // I am  no longer free
  <- .print("I told everyone I gave up on ",Gold);
     .broadcast(untell,allocatedTo(Gold,Ag)).

// someone else picked up the gold I was going after
// remove from bels and goals
@ppgd[atomic]
+picked(G)[source(A)] : .desire(handle(G))
  <- .print(A," has taken ",G," that I am pursuing! Dropping my intention.");
     !delGold(gold(X,Y));
     .dropDesire(handle(G)); // Rafa, do we need to drop drop the desire?
     .dropIntention(handle(G)).

// someone else picked up a gold I know about, remove from my bels
+picked(gold(X,Y)) : true 
  <- !delGold(gold(X,Y)).
  
@pdg1[atomic]
+!delGold(gold(X,Y)) : gold(X,Y) & allocatedTo(gold(X,Y),_) <- -gold(X,Y); -allocatedTo(gold(X,Y),_).
+!delGold(gold(X,Y)) : gold(X,Y) <- -gold(X,Y).
+!delGold(_) : true <- true.

+!init_handle(Gold) : true //free 
  <- //-free;
     .print("Dropping around(_,_) desires and intentions to handle ",Gold);
     .dropDesire(around(_,_));
     .dropIntention(around(_,_));
     .print("Dropped around(_,_) desires and intentions to handle ",Gold);
     !updatePos;
     !!handle(Gold). // must use !! to process handle as not atomic

+!updatePos : free & .desire(around(XA,YA))
  <- ?pos(XP,YP);
     !update(lastChecked(XP,YP));
     !update(goingTo(XA,YA)).
// do we need another alternative? I couldn't think of another. If free
// but no desire, probably was still going home which works
+!updatePos : true <- true.

+!handle(gold(X,Y)) 
  :  not free
  <- .print("Handling ",gold(X,Y)," now.");
     !pos(X,Y);
     !ensure(pick,gold(X,Y));
     +carrying_gold;
     // broadcast that I got the gold(X,Y), to avoid someone else to pursue this gold
     .broadcast(tell,picked(gold(X,Y)));
     ?depot(_,DX,DY);
     !pos(DX,DY);
     !ensure(drop, 0);
     !delCarrying_gold;
     !delGold(gold(X,Y)); 
     .print("Finish handling gold ",gold(X,Y));
     !!choose_gold.

// if ensure(pick/drop) failed, pursue another gold
-!handle(G) : G
  <- .print("failed to catch gold ",G);
     !delGold(G);
     !delCarrying_gold;
     !!choose_gold.
-!handle(G) : true
  <- .print("failed to handle ",G,", it isn't in the BB anyway");
     !delCarrying_gold;
     !!choose_gold.

// Hopefully going first to home if never got there because some gold was found
+!choose_gold 
  :  not gold(_,_)
  <- !update(free).

// Finished one gold, but others left
// find the closes gold among the known options, which hasn't been
// allocated to someone else
+!choose_gold 
  :  gold(_,_)
  <- .findall(gold(X,Y),gold(X,Y),LG); 
     !calcGoldDistance(LG,LD); .print("Gold distances: ",LD );
     .sort(LD,[d(_,G)|_]);
     .print("Next gold is ",G);
     !!handle(G).

+!calcGoldDistance([],[]) : true <- true.
+!calcGoldDistance([gold(GX,GY)|R],[d(D,gold(GX,GY))|RD]) 
  :  pos(IX,IY) 
  <- jia.dist(IX,IY,GX,GY,D);
     !calcGoldDistance(R,RD).


// BCG!
// !pos is used when it is algways possible to go 
// so this plans should not be used: +!pos(X,Y) : lastDir(skip) <-
// .print("It is not possible to go to ",X,"x",Y).
// in the future
//+lastDir(skip) <- .dropGoal(pos) 
+!pos(X,Y) : pos(X,Y) <- .print("I've reached ",X,"x",Y).
// is this OK?????????? (for the environment with failure)
/* idem o caso do around
+!pos(X,Y) : lastDir(skip)
  <- .print("GIVING UP!");
     .dropDesire(pos(X,Y));
     .dropIntention(pos(X,Y));
     !update(free).
     */
+!pos(X,Y) : not pos(X,Y)
  <- !next_step(X,Y);
     !pos(X,Y).


// need to check if really carrying gold, otherwise drop goal, etc...
// we should have environment feedback for pick!
+!ensure(pick,G) : pos(X,Y) & cell(X,Y,gold) //gold(X,Y) // & not carryingGold
  <- do(pick); do(pick). // do twice to ensure! (only in clima contest)
// fail if no gold there! handle will "catch" this failure.

+!ensure(drop, _) : pos(X,Y) & depot(_,X,Y) // & carryingGold
  <- do(drop). // we should have feedback for drop!
+!ensure(drop, N) : N < 3 & depot(_,X,Y)
  <- !pos(X,Y);
     !ensure(drop, N+1).
+!ensure(drop, _) : true // drop anywhere!
  <- do(drop).


// update bels
+!update(lastChecked(X,Y)) : lastChecked(_,_) <- -lastChecked(_,_); +lastChecked(X,Y).
+!update(lastChecked(X,Y)) : true <- +lastChecked(X,Y).
+!update(goingTo(X,Y)) : goingTo(_,_) <- -goingTo(_,_); +goingTo(X,Y).
+!update(goingTo(X,Y)) : true <- +goingTo(X,Y).

+!update(free) : free <- -free; +free.
+!update(free) : true <- +free.

+!update(lastDir(D)) : lastDir(_) <- -lastDir(_); +lastDir(D).
+!update(lastDir(D)) : true <- +lastDir(D).
//-!update(lastDir(D)) : true <- +lastDir(D). // not sure why this is needed!!!

/* restart */

@restart[atomic]
+restart : true
  <- .print("restarting!!");
     do(drop);
     .dropAllDesires; 
     .dropAllIntentions;
     !clearGold;
     !delCarrying_gold;
     !clearPicked;
     !clearPos;
     !repostGsize;
     !update(free).


/* end of a simulation */

@end[atomic]
+endOfSimulation(S,_) : true 
  <- !sayEndToLeader(S);
     !clearMyQuad;
     !clearGold;
     !delCarrying_gold;
     !clearPicked;
     !clearPos;
     //-pos(_,_); we must not remove the "pos" perceived in the same cycle than endOfSim
     !repostGsize;
     !update(free);
     .print("-- END ",S," --").

+!sayEndToLeader(S) : .myName(miner1) <- .send(leader, tell, endOfSimulation(S,n)).
+!sayEndToLeader(S) : true <- true.

// TODO: change semantic of "-" and create "--" to avoid these stupid plans :-)
     
+!clearMyQuad : myQuad(_,_,_,_) <- -myQuad(_,_,_,_).
+!clearMyQuad : true <- true.

+!clearGold : gold(X,Y) <- -gold(X,Y); !clearGold.
+!clearGold : true <- true.
-!clearGold : true <- true.

+!clearPicked : picked(_) <- -picked(_); !clearPicked.
+!clearPicked : true <- true.

+!clearPos : lastChecked(_,_) <- -lastChecked(_,_); !clearPos.
+!clearPos : goingTo(_,_) <- -goingTo(_,_); !clearPos.
+!clearPos : true <- true.

+!repostGsize : gsize(S,W,H) <- -gsize(S,W,H); +gsize(S,W,H)[source(percept)].
+!repostGsize : true <- true.

+!delCarrying_gold : carrying_gold <- -carrying_gold.
+!delCarrying_gold : true <- true.


