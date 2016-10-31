// Agent a in project testloop.mas2j

/* Initial beliefs and rules */


/* Initial goals */


/* Plans */

matches(any, _)     :- true.
matches(X,X)        :- true.
matches(Pat, What)  :- 
     Pat  =.. [PFunctor, PTerms, X] & .print("Pat=", Pat, " PF=",PFunctor,",",PTerms) &
     What =.. [Functor, Terms, _]   & .print("What=",What," F=", Functor, ",",Terms) &
     .length(PTerms,N1) & N1 \== 0 & 
     .length(Terms, N2) & N2 \== 0 & 
     matches(PFunctor, Functor)    &
     matchesList(PTerms, Terms).
matchesList([], [])  :- true.
matchesList([PH|PT], [H|T]) :-
     matches(PH, H) &
     matchesList(PT, T).
     
!start.
+!start <-  !report(games(a,b)); .stopMAS.

+!report(What) : matches(games(any,any), What) <- .print("ok: ", What).
+!report(_)                                    <- .print("irrelevant").

