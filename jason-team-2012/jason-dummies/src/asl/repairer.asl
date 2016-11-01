// Agent repairer in project mapc-jason-example.mas2j

/* Initial beliefs and rules */


!start.

/* Plans */

+!start : true <- .print("hello world.").

+step(_) <- skip.

