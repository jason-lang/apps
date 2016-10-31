!init.

+!init : nodes(Nodes)
 <-	// Asynchronous code
	for ( .range(Id,1,Nodes) )
	{
    	.concat("sender", Id, To_ag);
		.create_agent(To_ag, "sender.asl");
		//.print("created ",To_ag)
    }
	// Synchronous code
	//.wait(2000);     
	.broadcast(achieve, start(Nodes)).

+name(_) : .count(name(_), Nodes) & nodes(Nodes)
 <- .findall(Name, name(Name), Names);
	.print("Names=",Names);
	.abolish(name(_));
	.stopMAS.


