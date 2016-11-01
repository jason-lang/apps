// Agent explorer

/* Initial beliefs and rules */

// conditions for goal selection
is_energy_goal :- energy(MyE) & maxEnergy(Max) & MyE < Max/3.
is_probe_goal  :- position(MyV) & not probedVertex(MyV,_).
is_buy_goal    :- money(M) & M >= 10.
is_survey_goal :- position(MyV) & edge(MyV,_,unknown).  // some edge to adjacent vertex is not surveyed
                  
/* Initial goals */

+simStart
   <- .print("Starting sim");
      !select_goal.
   
+simEnd 
   <- .abolish(_); // clean all BB
      .drop_all_desires.
	  

+!select_goal : is_energy_goal <- !init_goal(be_at_full_charge); !!select_goal.
+!select_goal : is_probe_goal  <- !init_goal(probe);             !!select_goal.
+!select_goal : is_survey_goal <- !init_goal(survey);            !!select_goal.
+!select_goal : is_buy_goal    <- !init_goal(buy(battery));      !!select_goal.
+!select_goal                  <- !init_goal(random_walk);       !!select_goal.
-!select_goal[error_msg(M)]    <- .print("Error ",M);            !!select_goal.


+!init_goal(G)
    : step(S) & position(V) & energy(E) & maxEnergy(Max)
   <- .print("I am at ",V," (",E,"/",Max,"), the goal for step ",S," is ",G);
      !G.
+!init_goal(_)
   <- .print("No step yet... wait a bit");
      .wait(500);
	  !select_goal.

	  
/* Plans for energy */

+!be_at_full_charge 
    : energy(MyE) & maxEnergy(M) & MyE > M*0.9 // I am full, nothing to do
   <- .print("Charged at ",MyE).
+!be_at_full_charge 
    : energy(MyE)
   <- .print("My energy is ",MyE,", recharging");
      !do_and_wait_next_step(recharge);
	  !be_at_full_charge. // otherwise, recharge


/* Probe plans */

+!probe
   <- .print("Probing my location");
      !do_and_wait_next_step(probe).
	  
/* Probe plans */

+!survey
   <- .print("Surveying");
      !do_and_wait_next_step(survey).

/* Buy battery */

+!buy(X) 
    : money(M)
   <- .print("I am going to buy ",X,"! My money is ",M);
      !do_and_wait_next_step(buy(X)).


/* Random walk plans */

+!random_walk 
    : position(MyV) // my location
   <- .setof(V, edge(MyV,V,_), Options);
      .nth(math.random(.length(Options)), Options, Op);
      .print("Random walk options ",Options," going to ",Op);
	  !do_and_wait_next_step(goto(Op)).
	  
	  
/* general plans */

// the following plan is used to send only one action each cycle
+!do_and_wait_next_step(Act)
    : step(S)
   <- Act; // perform the action (i.e., send the action to the simulator)
      !wait_next_step(S). // wait for the next step before going on

+!wait_next_step(S)  : step(S+1).
+!wait_next_step(S) <- .wait( { +step(_) }, 500, _); !wait_next_step(S).
   
+step(S) : not simStart <- +simStart.
+step(S) <- .print("Current step is ", S).


// store perceived probed vertexs in the BB
+probedVertex(L,V) <- +probedVertex(L,V). 

// store edges in the BB
@lve1[atomic]
+visibleEdge(V1,V2)    
   <- +edge(V1,V2,unknown);
      +edge(V2,V1,unknown).
	  
@lve12[atomic]
+surveyedEdge(V1,V2,C) 
   <- -edge(V1,V2,_); -edge(V2,V1,_);
      +edge(V1,V2,C); +edge(V2,V1,C).

