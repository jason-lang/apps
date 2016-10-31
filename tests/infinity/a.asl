// Agent infinite (and beyond!!!) in project session.mas2j

/* Initial beliefs and rules */

p(X) :- X = f(X).

q(X) :- X = f(Y).

test(Glob) :-
 Merge = choice([Off,Fork]) &
 Off=seq(tell(b,c,offer),seq(tell(c,b,counter),Merge)) &
 Fork=fork(seq(tell(b,s,final),end),seq(tell(b,c,result),end)) &
 Glob = seq(tell(s,b,item),Merge).

/* Initial goals */

!start.

/* Plans */


+!start : test(Z)  <-  .print(Z).

+!g <- ?t(A); A = f(f(f(f(f(Y))))); .print(Y).

// +!start : p(g(X))  <- .print("Test 2 should fail").

// +!start : p(f(f(f(f(f(Y))))))  <- .print("Test 3 should succeed ",Y).

// +!start : p(f(f(f(f(f(f(f(f(f(f(Y)))))))))))  <- .print("Test 4 should succeed").

// +!start : p(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(Y)))))))))))))))))))))))))))))))  
  // <- .print("Test 5 should succeed").

//+!start :  p(f(f(f(f(f(f(f(f(f(g(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(Y)))))))))))))))))))))))))))))))  
//<- .print("Test 6 should fail (using p, infinite term inside hence only terms consisisting of infinite f succeed)").

// +!start :  q(f(f(f(f(f(f(f(f(f(g(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(f(Y)))))))))))))))))))))))))))))))  
// <- .print("Test 7 should succeed (using q, no infinite term inside hence any argument of q fits)").

