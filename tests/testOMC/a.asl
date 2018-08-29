
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

   .wait(2000);
   .print("end test");
   //.stopMAS;
.
