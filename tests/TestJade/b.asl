// Agent b in project TestJade.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- 
   .send(a,tell,hello);
   .broadcast(tell,alo);
   .send(j,tell,vl(10,bob)).

