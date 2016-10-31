// leader agent

/* quadrant allocation */

@quads[atomic]
+gsize(S,W,H) : true
  <- .print("Defining quadrants for ",W,"x",H," simulation ",S);
     +quad(S,1, 0, 0, W div 2 - 1, H div 2 - 1);
     +quad(S,2, W div 2, 0, W-1, H div 2 - 1);
     +quad(S,3, 0, H div 2, W div 2 - 1, H - 1);
     +quad(S,4, W div 2, H div 2, W - 1, H - 1);
     .print("Finished all quadrs for ",S).

+myInitPos(S,X,Y)[source(A)]
  :  myInitPos(S,X1,Y1)[source(miner1)] & myInitPos(S,X2,Y2)[source(miner2)] &
     myInitPos(S,X3,Y3)[source(miner3)] & myInitPos(S,X4,Y4)[source(miner4)]
  <- .print("*** InitPos ",A," is ",X,"x",Y);
     !assignAllQuads(S,[miner1,miner2,miner3,miner4],[1,2,3,4]).

+myInitPos(S,X,Y)[source(A)] : true <- .print("- InitPos ",A," is ",X,"x",Y).

// Rafa, talvez refazer essa parte usando o sort. (TODO)

+!assignAllQuads(_,[],_) : true <- true.
+!assignAllQuads(S,A,I) : not quad(S,4,_,_,_,_)
  <- .wait("+quad(S,4,_,_,_,_)", 500); // wait for quad calculation to finish
     !!assignAllQuads(S,A,I). 
// Give priority based on agent number, this is NOT the optimal allocation
+!assignAllQuads(S,[A|T],[I|L]) : true
  <- ?quad(S,I,X1,Y1,_,_);
     ?myInitPos(S,X2,Y2)[source(A)];
     jia.dist(X1,Y1,X2,Y2,D);
     !assignQuad(S,A,q(I,D),AQ,L,[],NL); // Jomi: after fixing that bug q(AQ,_) doesn't work in 4th par as before, probably not right yet...
     .print(A, "'s Quadrant is: ",AQ);
     AQ = q(Q,_); // Jomi: this is the extra line needed after fixing the bug variable name conflict in posted events
     ?quad(S,Q,X3,Y3,X4,Y4);
     .send(A,tell,myQuad(X3,Y3,X4,Y4));
     !assignAllQuads(S,T,NL).

// Already checked all quadrants available for agent A
+!assignQuad(_,A,Q,Q,[],L,L) : true <- true.

+!assignQuad(S,A,q(ID,D),Q,[I|T],L,FL) : true
  <- ?quad(S,I,X1,Y1,_,_);
     ?myInitPos(S,X2,Y2)[source(A)];
     jia.dist(X1,Y1,X2,Y2,ND);
     !getSmaller(q(ID,D),q(I,ND),SQ,LI); // shall we add conditional expressions to AS?
     !assignQuad(S,A,SQ,Q,T,[LI|L],FL).

+!getSmaller( q(Q1,D1), q(Q2,D2), q(Q1,D1), Q2 ) : D1 <= D2 <- true.
+!getSmaller( q(Q1,D1), q(Q2,D2), q(Q2,D2), Q1 ) : D2 <  D1 <- true.


/* negotiation for found gold */

+bidFor(Gold,D)[source(M1)]
  :  bidFor(Gold,_)[source(M2)] & bidFor(Gold,_)[source(M3)] &
     M1 \== M2 & M1 \== M3 & M2 \== M3
  <- .print("bid from ",M1," for ",Gold," is ",D);
     !allocateMinerFor(Gold);
     !clearBids(Gold).
+bidFor(Gold,D)[source(A)] : true
  <- .print("bid from ",A," for ",Gold," is ",D).  
 
+!allocateMinerFor(Gold) : true
  <- .findall(op(Dist,A),bidFor(Gold,Dist)[source(A)],LD);
     .sort(LD,[op(DistCloser,Closer)|_]);
     DistCloser < 1000;
     .print("Gold ",Gold," was allocated to ",Closer, " options was ",LD);
     .broadcast(tell,allocatedTo(Gold,Closer)).
-!allocateMinerFor(Gold) : true
  <- .print("could not allocate gold ",Gold).


/* end of simulation plans */     

@end[atomic]
+endOfSimulation(S,_) : true 
  <- .print("-- END ",S," --");
     !clearInitPos(S).

+!clearInitPos(S) : myInitPos(S,_,_) <- -myInitPos(S,_,_); !clearInitPos(S).
+!clearInitPos(_) : true <- true.

+!clearBids(Gold) : bidFor(Gold,_) <- -bidFor(Gold,_); !clearBids(Gold).
+!clearBids(Gold) : true <- true.

