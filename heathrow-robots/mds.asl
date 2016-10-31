free.   // I'm free, initially
mds(5). // There are 5 MDS robots (including me)

// perception of an unattented luggage at Terminal/Gate,
// with report number RN
+unattended_luggage(Terminal,Gate,RN) : true
      <- !negotiate(RN).

// negotiation on which MDS robot will deal with a particular
// unattended luggage report
+!negotiate(RN) : free 
      <- .myName(I);                      // Jason internal action
         +bids(RN,1);                     // number of bids I'm aware of
         mds.calculateMyBid(RN,MyBid);    // user internal action
         +winner(RN,I,MyBid);             // assume winner until someone else bids higher
         .broadcast(tell, bid(RN,MyBid)). // tell all others what my bid is

+!negotiate(RN) : not free 
      <- .broadcast(tell, bid(RN,0)).     // I can't bid to help with this

@pb1[atomic]  // for a bid better than mine
+bid(RN,B)[source(Sender)] : winner(RN,I,MyBid)
                           & .myName(I) & MyBid < B
      <- -winner(RN,I,MyBid);
         +winner(RN,Sender,B);
         .print("just lost to another MDS").

@pb2[atomic] // for other bids when I'm still the winner
             // and negotiation hasn't finished yet
             // this plan needs to be atomic
+bid(RN,B) : .myName(I) & winner(RN,I,MyBid)
           & bids(RN,N) & mds(M) & N < M
      <- !incBidCounter(RN);
         !check_negot_finished(RN).

// TODO: cope with two equal bids
@pb4  // just to remember who won anyway
+bid(RN,B)[source(Sender)] : winner(RN,W,WB) & B > WB
      <- -winner(RN,W,WB);
         +winner(RN,Sender,B).

@pb5 // ignore loosing bids, as I'm not the winner for this RN
+bid(RN,B) : true <- true.

+!check_negot_finished(RN) : .myName(I) & winner(RN,I,MyBid)
                           & bids(RN,N) & mds(M) & N >= M
      <- .print("*************** I won!!!!");
         -free;
         !check_luggage(RN);
         !finish_case(RN).

+!check_negot_finished(RN) : true <- true.

+!incBidCounter(RN) : true
      <- -bids(RN,N); +bids(RN,N+1).

+!check_luggage(RN) : true     // mybid was the best one
      <- ?unattended_luggage(T,G,RN);
         !go(T,G);             // not included here
         !do_all_checks(RN).   // not included here

+!finish_case(RN) : bomb(RN,Type) // tell bd1 about the bomb
      <- .send(bd1, tell, bomb(RN,Type)).

+!finish_case(RN) : true // it wasn't a bomb afterall
      <- +free;          // so nothing else to do, just tidy up
         -bids(RN,X).

// fake plans (for the time being)
+!go(T,G) : true <- true.
+!do_all_checks(RN) : true <- +bomb(RN,bioBomb).
