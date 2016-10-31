!start.

+!start <- 
	NUM = 1000000;
	SIZE = 10000;

	for ( .range(I, 1, NUM)) {
	    T = system.time;

		for ( .range(J, 1, SIZE)) {
			//I1 = I;	// slow
			I1 = NUM;	// fast

			J1 = J;
			.concat("Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-Agent-", I1, "-", J1, Name);
			.create_agent(Name, "agent.asl");
		}

		D = system.time - T;
		.print("Started ", I, "*", SIZE, " agents in ", D, "ms");
	}
.

