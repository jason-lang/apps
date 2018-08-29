!g.
!d.

+!g <- .print("a"); .wait(1000);
       !g1;
       !g;
       .

+!g1 <- .print(b).

+!d <- .wait(500); .drop_future_intention(g1); !d.
