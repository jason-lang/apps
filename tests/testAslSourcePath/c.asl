// Agent c in project ts.mas2j

{ include("hello.asl") }

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- !inc_goal.

