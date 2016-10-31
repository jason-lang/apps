!start. // initial goal.

+!start <- +maillog(timestamp(2009,9,9,2,2,2),"a","b",14,"c"); ?print.
-!start <- .print(end); .stopMAS.

print :- maillog(A,B,C,D,E) & .print(maillog(A,B,C,D,E)) & .fail.
      

