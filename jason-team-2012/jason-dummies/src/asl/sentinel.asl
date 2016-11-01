// Agent sentinel in project mapc-jason-example.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- .print("hello world.").

+step(_) <- skip.

