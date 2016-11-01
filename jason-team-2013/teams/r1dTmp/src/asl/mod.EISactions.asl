/*
 * action: GOTO
 */
+!goto(Op):
    energy(MyE) & position(MyV) & ia.edge(MyV, Op, W) & W > MyE //I don't have energy to go
<-
    .print("I'm enabled. My current energy is ", MyE, " but I need ", W);
    !recharge. //firstly, I'm going to recharge.
    
+!goto(Op):
    position(MyV) //I can go!
<-
    .print("I'm enabled. My current vertex is ", MyV, " and I'm going to' ", Op);
    !do(goto(Op)).
    
+!goto(Op):
    true
<-
    .print("I don't know my position and I'm going to ", Op);
    !do(goto(Op)).
    
/*
 * action: SURVEY
 */
+!survey:
    true
<- 
    .print("Surveying");
    !do(survey).

/*
 * action: RECHARGE
 */
+!recharge: 
    energy(MyE)
<- 
    .print("My energy is ",MyE,", recharging");
    !do(recharge).
    
+!recharge: 
    true
<- 
    .print("I don't know my energy and I'm going to recharge");
    !do(recharge).

/*
 * action: SKIP
 */
+!skip:
    true
<- 
   .print("Skipping");
   !do(skip).

/*
 * action: PROBE
 */   
+!probe:
	true
<- 
	.print("Probing my location");
	!do(probe).
	
+!probe(Op):
    true
<-
    .print("Probing vertex ", Op);
    !do(probe(Op)).
    
/*
 * action: INSPECT
 */
+!inspect:  
    true
<- 
    .print("Inspecting my location");
    !do(inspect).
    
+!inspect(Op):  
    true
<- 
    .print("Inspecting agent ", Op);
    !do(inspect(Op)).
    
/*
 * action: REPAIR
 */
+!repair(Op):  
    true
<- 
    .print("I am going to repair an entity and its name is ", Op);
    !do(repair(Op)).
    
/*
 * action: ATTACK
 */
 +!attack(Op):  
    true
<- 
    .print("I am going to attack an entity and its name is ", Op);
    !do(attack(Op)).

/*
 * action: BUY
 */
+!buy(Op):
    money(M)
<- 
    .print("I am going to buy ", Op,"! My money is ",M);
    !do(buy(Op)).
    
+!buy(Op):
    true
<- 
    .print("I don't know my money and I am going to buy ", Op);
    !do(buy(Op)).
    
/*
 * action: PARRY
 */
+!parry:  
    true
<- 
    .print("I am going to parry because there's a saboteur here");
    !do(parry).