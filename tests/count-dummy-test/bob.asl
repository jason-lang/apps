// Agent bob in project count-dummy-test.mas2j

/* Include generic conference behavior */
{ include("person.asl") } 

/* Initial beliefs and rules */
a(1).
a(2).

/* Initial goals */

!start.

/* Plans */

+!start
  <- .count(a(_), C);
     .println("Bob Count (classic) = ", C);
     .println("Bob Count (function) = ", .count(a(_)) );
	 !init_person.

