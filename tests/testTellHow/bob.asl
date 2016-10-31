!start.

   @test
   +!test(X) <-
       Y = 20;
       .print(X, " ", Y); .list_plans;
       .puts("vals are #{X} and #{Y}.");
   .

   +!start <-
       .create_agent(other, "empty_file.asl");
       .plan_label(PlanT, test);
       .send(other, tellHow, PlanT);
       !test(10);
       .send(other, achieve, test(10));
   .
