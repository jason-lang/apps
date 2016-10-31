// Agent monitor in project infinite1.mas2j

/* Initial beliefs and rules */

equivalent(end, end).
equivalent(fork(T1, T2), end) :- equivalent(T1, end) & equivalent(T2, end).


/* Compact version of the global type, with infinite terms */
global_type(brokering, Glob) :-
   Merge = choice([Off,Fork]) &
   Off=
   seq(msg(b,c,tell(offer(Item, _))),
      seq(msg(c,b,tell(counter(Item, _))),Merge)) &
   Fork= fork(seq(msg(b,s,tell(final(Res, c, Item, _))),end),
              seq(msg(b,c,tell(result(Res, Item, _))),end)) &
   Glob = seq(msg(s,b,tell(item(c, Item))),Merge). 

/* Verbose version of the global type, without infinite terms */
/* global_type(brokering, Glob) :-
Merge = choice([Off,Fork]) &
Off=
seq(msg(b,c,tell(offer(Item, _InitialOffer))),
   seq(msg(c,b,tell(counter(Item, _CounterOffer))),
      choice(seq(msg(b,c,tell(offer(Item, _InitialOffer))),
                seq(msg(c,b,tell(counter(Item, _CounterOffer)))),
				   choice(seq(msg(b,c,tell(offer(Item, _InitialOffer))),
                      seq(msg(c,b,tell(counter(Item, _CounterOffer)))),
					     choice(seq(msg(b,c,tell(offer(Item, _InitialOffer))),
                             seq(msg(c,b,tell(counter(Item, _CounterOffer)))),
							 Fork), Fork), 
				   Fork), Fork),
	  Fork), Fork)
)) &
Fork= fork(seq(msg(b,s,tell(final(Res, c, Item, LastOffer))),end),seq(msg(b,c,tell(result(Res, Item, LastOffer))),end)) &
Glob = seq(msg(s,b,tell(item(c, Item))),Merge).   */

current_state(initial).

next(seq(A,T),A,T).
next(choice([T1|_]),A,T2) :- next(T1,A,T2). 
next(choice([_|L]),A,T) :- next(choice(L),A,T).
next(fork(T1,T2),A,fork(T3,T2)) :- next(T1,A,T3). 
next(fork(T1,T2),A,fork(T1,T3)) :- next(T2,A,T3).

type_check(msg(S, R, C), NewState) :- 
   current_state(LastState) &
   next(LastState, msg(S, R, C), NewState).

/* Initial goals */

/* Plans */

/* Monitor's plans */

@register
+register(global_type(Name), List) : current_state(initial) & global_type(Name, G) 
   <- !move_to_state(G); 
      +global_type_participants(global_type(Name), List).

@move2state[atomic] 
+!move_to_state(NewState) : current_state(LastState) 
   <- -current_state(LastState); 
      +current_state(NewState).

@successfulMove[atomic] 
+!type_check_message(msg(S, R, C)) : type_check(msg(S, R, C), NewState)  
   <- !move_to_state(NewState);  
      .print("\nMessage ", msg(S, R, C), "\nleads to state ", NewState, "\n\n");
      .send(S, tell, ok_check(msg(S, R, C))).

@failingMoveAndProtocol
+!type_check_message(msg(S, R, C)) : session_participants(session(Name), List) 
   <- .send(S, tell, fail_check(msg(S, R, C))); 
      !multicast(List, tell, protocol_failed(Name));
      !housekeep.

@messageReception[atomic] 
+msg(S, R, C): current_state(State) 
   <- -msg(S, R, C); 
      !type_check_message(msg(S, R, C)).

@successfulProtocol
+current_state(State) : equivalent(State, end) 
                        & session_participants(session(Name), List) 
   <- !multicast(List, tell, protocol_succeeded(Name));
      !housekeep.

@move2state[atomic] +!move_to_state(NewState) : current_state(LastState) <- -current_state(LastState); +current_state(NewState).


+!multicast([H|T], Performative, Content) : true 
   <- .send(H, Performative, Content); 
      !multicast(T, Performative, Content).
	  
+!multicast([], _, _) : true 
   <- true.
	  
+!housekeep : global_type_participants(global_type(Name), List) 
   <- !move_to_state(initial);
      -global_type_participants(global_type(Name), List).
