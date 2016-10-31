// Agent creator in project TestKill.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- .create_agent(bob, "bob.asl"); .wait(2000); .kill_agent(bob).

