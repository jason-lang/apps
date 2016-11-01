{ include("mod.common.asl") }

//Nao eh necessario survey em todas as arestas... perde muito tempo. Ano passado foi feito e retirado.

+!wait_and_select_goal <- !select_goal.
-!wait_and_select_goal[error(deadline_reached)] <- .print("Deadline reached"); !select_goal.

+!select_goal: is_energy_goal 
		<- !init_goal(recharge).
+!select_goal : is_wait_repair_goal(V) 
		<- .print("Waiting to be repaired. Recharging..."); 
    		!init_goal(recharge).
    		
+!select_goal: is_disabled & get_vertex_to_go_be_repaired_appointment(D, Path) 
		<- 
			.print("I have an appointment with some repairer. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).
+!select_goal: is_disabled & get_vertex_to_go_repair(D, Path) 
		<- 
			.print("I'm forever alone. I'm going to ", D, " using path: ", Path);
			!init_goal(gotoPath(Path)).	
    		
+!select_goal : is_parry_goal 
		<- !init_goal(parry).
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
    
+!initSpecific.
+!processAfterStep(S).
    