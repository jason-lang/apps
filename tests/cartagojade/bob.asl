// Agent bob in project cartagojade.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true 
   <- println("hello world.");
      .send(alice,achieve,start).

