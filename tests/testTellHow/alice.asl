   !start.

   @destructure_query
   +!destructure_query(Strt, Fn, Args, Ann) <- 
       Strt =.. [Fn, Args, Ann];
       ?Strt;
   .

   @test
   +!test(Which) <-
       if ( Which == strt_to_list ) {
           Strt = foo(1, 2, 3)[bar];
           +Strt;
           !destructure_query(Strt, Fn, Args, Ann);
           .print(Strt, " =.. [", Fn, ", ", Args, ", ", Ann, "] exists");
       }
       if ( Which == list_to_strt ) {
           +baz(4, 5, 6)[quux];
           !destructure_query(StrtBis, baz, [4, 5, 6], [quux]);
           .print(StrtBis, " =.. [baz, [4, 5, 6], [quux]] exists");
       }
   .

   +!start <-
       .wait(1000);
       .create_agent(another, "empty_file.asl");
       .plan_label(PlanD, destructure_query);
       .send(another, tellHow, PlanD);
       .plan_label(PlanT, test);
       .send(another, tellHow, PlanT);
       !test(strt_to_list);
       !test(list_to_strt);
       .send(another, achieve, test(strt_to_list));
       .send(another, achieve, test(list_to_strt));
   .

