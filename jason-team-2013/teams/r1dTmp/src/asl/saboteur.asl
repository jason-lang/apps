{ include("mod.common.asl") }

+!wait_and_select_goal <- !select_goal.
-!wait_and_select_goal[error(deadline_reached)] <- .print("Deadline reached"); !select_goal.

+!select_goal: is_energy_goal 
		<- !init_goal(recharge).
+!select_goal: is_survey_goal   
		<- !init_goal(survey).
+!select_goal                  
		<- !init_goal(random_walk).
		

/*
 * These functions must be dependent of each kind of agent because they will
 * need to share some information with the other friends of the same kind
 */
@do0[atomic]
+!do(Act): 
    step(S) & stepDone(S)
<- 
    .print("ERROR! I already performed an action for this step! ", S).

@do1[atomic]
+!do(Act): 
    true
<- 
    !commitAction(Act).
    