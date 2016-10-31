// Agent a in project tis.mas2j

/* Beliefs */

v([a,b]).

/* Initial goals */

!start.

/* Plans */

+!start : v(X) 
   <- !test(a(Y)); !test("oi"); !test(10); !test(a(10));
      !test([a,b,c]); !test([a,b,c(HH)]);
      !test(OO); !test(a);
      .stopMAS.

+!test(X) : .string(X) & .ground(X) <- .print("string. ",X).
+!test(X) : .number(X) & .ground(X) <- .print("number. ",X).
+!test(X) : .atom(X) & .structure(X) <- .print("atom. ",X).
+!test(X) : .list(X) & .ground(X) & .structure(X) <- .print("ground list. ", X).
+!test(X) : .list(X) & not .ground(X)  & .structure(X) <- .print("unground list. ", X).
+!test(X) : .ground(X) & .structure(X)<- .print("ground structure. ",X).
+!test(X) : not .ground(X) & .structure(X) <- .print("not ground structure. ",X).
+!test(X) : not .ground(X)  <- .print("var").
+!test(X) <- .print("unknown type! ",X).



