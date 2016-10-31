// Agent b in project tactat.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- .print("hello world.").

+?vl(X) <- .print("received ask"); .wait(2000); X=100; .print("answered").

