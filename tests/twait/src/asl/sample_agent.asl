!t.
!start.

+!start <-
	.println(1);
    .wait(5000);  // test A --> print    1 resumed 2 resumed
	//.wait(false); // test B --> print 1 resumed
	.println(2);
	.

+!t <-
		.wait(500);
		.suspend(start);
		.wait(2000);
		.resume(start);
	.


^!start[state(resumed)] <- .println("resumed").
