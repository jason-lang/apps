!change.

!list_all.

+!change : .count(x(_),N)
   <- V = math.round(math.random(1000));
      +sector(V, 35, 15, 20, 15, math.random(500)); 
      +x(N+1);
      .print("last value ",N, ", added ", N+1);
	  !test(V).
+!test(V): sector(V,_,_,_,_,_) <- .print(ok).
+!test(V) <- .print("ops for sector ",V).

+!list_all 
   <- .findall(V, x(V), L); .print("all values: ",L);
      .findall(X, sector(_, _, _, _, _, X), L2); .print("all values of sectors: ",L2).
   
