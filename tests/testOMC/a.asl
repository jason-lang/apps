/* output

[a] g1
[a] g1
[a] no maintenance condition
[a] Finish g
[a] g1
[a] g1
[a] goal achieved by other means
[a] Finish g
[a] g1
[a] g1
[a] fail condition
[a] g failed!
[a] end test

*/


mb.

!g.
!t.

{begin omc(g1,fb,mb)}
+!g1 <- .wait(500);.print(g1).
{end}

+!g <- !g1; .print("Finish g").
-!g <- .print("g failed!").

+!t <-
   .list_plans;
   .wait(1100);
   .print("no maintenance condition");
   -mb;

   !!g;
   .wait(1100);
   .print("goal achieved by other means");
   +g1;
   .wait(100);
   -g1;

   !!g;
   .wait(1100);
   .print("fail condition");
   +fb;

   .wait(500);
   .print("end test");
   .stopMAS;
.
