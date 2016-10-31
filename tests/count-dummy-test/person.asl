// Agent person in project count-dummy-test.mas2j

/* Initial beliefs and rules */


/* Initial goals */


/* Plans */

+!init_person
  <- .count(a(_), C);
     .println("Person Count (classic) = ", C);
     .println("Person Count (function) = ", .count(a(_)) ).

