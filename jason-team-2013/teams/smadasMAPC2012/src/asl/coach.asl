/*
 * This agent is the guy responsible to get some informations about the current match and the past matches of the current opponent.
 * He uses this information to changes the buy sub-strategy. If some team are following our malicious saboteur, so we keep buying. If not, we stop to buy.
 */

!start.

/*
 * Strategy 1: Try buy!
 * Strategy 2: Do not buy!
 */
+!start: 
    true 
<- 
    !loadAgentNames;
    .print("Agent coach loaded.").

{ include("loadAgents.asl") }

+entity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange, S):
    not friend(_, Entity, _) 
<-
    !processHealth(Team, Type, Health, S);
    !processStrength(Team, Type, Strength, S);
    !sendMeStrategy(Team);
    -entity(Entity, Team, Type, V, Energy, MaxEnergy, Health, MaxHealth, Strength, VisRange, S);
    .print("Receive data from entity ", Entity, " of team ", Team, " of type ", Type, " with Health ", Health, " and Strength ", Strength).
    
+!processHealth(Team, Type, Health, S):
    Type == "Saboteur" & Health >= 4
<-
    .print("Team ", Team, " buy health");
    -~buy(Team, Type, health);
    +buy(Team, Type, health).
+!processHealth(Team, Type, Health, S):
    Type == "Saboteur" & Health <= 3 & not buy(Team, Type, health) & S > 300
<-
    .print("Team ", Team, " do not buy health");
    +~buy(Team, Type, health).
+!processHealth(_, _, _, _): true <- true.

+!processStrength(Team, Type, Strength, S):
    Type == "Saboteur" & Strength >= 4
<-
    .print("Team ", Team, " buy strength");
    -~buy(Team, Type, strength);
    +buy(Team, Type, strength).
+!processStrength(Team, Type, Strength, S):
    Type == "Saboteur" & Strength <= 3 & not buy(Team, Type, strength) & S > 300
<-
    .print("Team ", Team, " do not buy strength");
    +~buy(Team, Type, strength).
+!processStrength(_, _, _, _): true <- true.
    
+ranking(Rank):
    true
<-
    .print("Receive rank ", Rank).
    
+!sendMeStrategy(Team):
    buy(Team, _, _) | not ~buy(Team, _, _)
<-
    .print("Sending strategy 1 X");
    !sendStrategy(1).
    
+!sendMeStrategy(Team):
    simEnd(Team) & ~buy(Team, _, _) & not buy(Team, _, _)
<-
    .print("Sending strategy 2 X");
    !sendStrategy(2).
    
+!sendMeStrategy(Team):
    true
<-
    .print("Sending strategy 1 Y");
    !sendStrategy(1).
   
+!sendStrategy(Strategy). 
+!sendStrategy(Strategy):
    true
<-
    .print("Sending strategy ", Strategy);
    .send(saboteur1, achieve, setStrategy(Strategy));
    .send(saboteur2, achieve, setStrategy(Strategy));
    .send(saboteur3, achieve, setStrategy(Strategy));
    .send(saboteur4, achieve, setStrategy(Strategy)).
    
+!setSimEnd(Team):
    true
<-
    .print("Received simEnd!");
    +simEnd(Team).
    
/* The round finished for all agentes */
+simEnd: 
	.count(friend(_, _, _), NAgents) & .count(simEnd[source(_)], NAgents)
<-
	.broadcast(achieve, finishSimulation);
    .abolish(simEnd);
    .print("All agents finished!").
+!finishSimulation.
	
+simEnd[source(Ag)]: 
	.count(simEnd[source(_)],NEnds)
<-
    .print("Received simEnd from ", Ag, " ", NEnds).
