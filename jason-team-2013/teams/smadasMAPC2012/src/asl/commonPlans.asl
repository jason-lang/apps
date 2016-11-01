!start.

+!start: .my_name(MyName) <- 
	!loadAgentNames;
	?friend(MyName, MyNameContest, _);
	+myNameInContest(MyNameContest).

+simStart:
    true
<-
    .print("Contest started!").
    
+vertices(V)[source(angel)]:
    true
<-
    .print("Max vertices is ", V);
    ia.setMaxVertices(V).
    
+vertices(V):
    true
<-
    .print("Received max vertices is ", V);
    .send(angel, achieve, tellVertices(V)).
    
+edges(E)[source(angel)]:
    true
<-
    .print("Max edges is ", E);
    ia.setMaxEdges(E).
    
+edges(E):
    true
<-
    .print("Received max edges is ", E);
    .send(angel, achieve, tellEdges(E)).
    
+steps(S)[source(percept)]:
    true
<-
    +steps(S);
    .print("Received steps is ", S);
    .send(angel, achieve, tellSteps(S)).
    
+steps(S)[source(angel)]:
    true
<-
    +steps(S);
    .print("Max steps is ", S).
    
    
/*
@simEndP1[atomic]
+simEnd[source(percept)]:
    true 
<-
    !notifyCoachSimEnd;
    !finishSimulation. */
    
+!finishSimulationLastStep:
    .my_name(MyName)
<-
    !notifyCoachSimEnd.

+!finishSimulation:
    myNameInContest(MyName)
<-
    .print("Contest finished!"); 
    !resetSystem;
    +myNameInContest(MyName).

+!finishSimulation:
    true
<-
    .print("Contest finished, and I do not know my name!");
    .send(angel, achieve, tellMyName).

@resetSystem1[atomic]
+!resetSystem:
    true
<-
    .abolish(_); // clean all BB
    .drop_all_intentions;
    .drop_all_desires;
    ia.resetGraph.

+!init_goal(G): 
    money(M) & step(S) & position(V) & energy(E) & maxEnergy(Max) & lastActionResult(Result) & score(Score) & health(Health) & lastAction(LastAction) & lastStepScore(LastScore) & zonesScore(ZoneScore) & zoneScore(MyZoneScore)
<- 
    .print("I am at ",V," (",E,"/",Max,"), my health is ", Health, " the goal for step ",S," is ",G, " and I have ", M, " of money. My last result was ", Result, ". My last action was ", LastAction, ". The score is ", Score, " and my last score was ", LastScore, " with zones ", ZoneScore, " and my zone is ", MyZoneScore);
    !G.
    
+!init_goal(G): 
    step(S) & position(V) & energy(E) & maxEnergy(Max)
<- 
    .print("Something wrong... I'going try to don't lose the step. I'm at ",V," (",E,"/",Max,"). My action for step ",S," is ", G);
    !G.
      
+!init_goal(_)
<- 
    .print("No step yet... wait a bit");
    .wait(500);
    !select_goal.
    
+!survey:
    true
<- 
    .print("Surveying");
    !do(survey).

+!recharge: 
    energy(MyE)
<- 
    .print("My energy is ",MyE,", recharging");
    !do(recharge).
    
+!recharge: 
    true
<- 
    .print("My energy is (I don't know), recharging");
    !do(recharge).

/* GOTO disabled state */
+!goto(Op):
    is_disabled & maxEnergy(MaxE) & position(MyV) & ia.edge(MyV, Op, W) & maxWeight(W) & W > MaxE //I have to buy more batteries and I don't have enough money
<-
    .print("I'm disabled. My max energy is ", MaxE, " but I need ", 10, " and I don't have money");
    !recharge. //TODO I have to choose an alternative: In order to don't lose a step, I choose recharge 
    
+!goto(Op):
    is_disabled & energy(MyE) & position(MyV) & ia.edge(MyV, Op, W) & maxWeight(W) & W > MyE //That's too expensive
<-
    .print("I'm disabled. My current energy is ", MyE, " but I need ", W);
    !recharge. //firstly, I'm going to recharge.
    
+!goto(Op):
    is_disabled & position(MyV) & ia.edge(MyV, Op, W) & maxWeight(W) //I can go!
<-
    .print("I'm disabled. My current vertex is ", MyV, " and I'm going to' ", Op);
    !do(goto(Op)).

/* GOTO enabled state */    
+!goto(Op):
    maxEnergy(MaxE) & position(MyV) & ia.edge(MyV, Op, W) & W > MaxE //I have to buy more batteries 
    &  
    money(MyM) & costBattery(CostBattery) & MyM >= CostBattery //And I have money to buy one
<-
    .print("I'm enabled. My max energy is ", MaxE, " but I need ", W);
    !do(buy(battery)). //firstly, I'm going to buy a new battery.
    
+!goto(Op):
    maxEnergy(MaxE) & position(MyV) & ia.edge(MyV, Op, W) & W > MaxE //I have to buy more batteries and I don't have enough money
<-
    .print("I'm enabled. My max energy is ", MaxE, " but I need ", W, " and I don't have money");
    !recharge. 
    
+!goto(Op):
    energy(MyE) & position(MyV) & ia.edge(MyV, Op, W) & W > MyE //That's too expensive
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
    .print("I think I lost a step").
    
+!tryAskBuy:
    money(M)
<-
    .print("I am going to ask to buy something! My money is ",M);
    +askedBuy;
    .send(inspector1, achieve, conceivePermissionToBuy);
    !select_goal.
    
+!skip:
    true
<- 
   .print("Nothing to do");
   !do(skip).
   
+!wait_next_step(S)  : step(S+1).
+!wait_next_step(S) <- .wait( { +step(_) }, 500, _); !wait_next_step(S).
   
/* Walk to be repaired */
+!repair_walk: 
    gotoVertexRepair(D, RepairerName, []) & .my_name(MyName) & step(S)
<- 
    .send(RepairerName, achieve, notifyRepairerFree);
    -gotoVertexRepair(_,_,_);
    .print("I'm at the combined place, so I'm going to cancel my appointment.");
    -+hit(S).
    
+!repair_walk: 
    gotoVertexRepair(D, RepairerName, [H|T]) & position(H)
<- 
    -gotoVertexRepair(_, _, _);
    +gotoVertexRepair(D, RepairerName, T);
    !repair_walk.
    
+!repair_walk: 
    gotoVertexRepair(D, RepairerName, [H|T]) & position(MyV) & ia.edge(MyV,H,_)
<- 
    .print("I'm going to be cured by the agent ", RepairerName, " at ",H);
    !goto(H).
    
+!repair_walk: 
    gotoVertexRepair(D, RepairerName, [H|T]) & position(MyV) & not ia.edge(MyV,H,_) & .my_name(repairer1) & step(S)
<-  
    .print("Ops! REPAIR Wrong way to ",H, ". I'm going to select other goal to do.");
    
    .abolish(hit(_));
    +hit(S);
    .abolish(hit(repairer1, _));
    +hit(repairer1, Pos);
    
    .abolish(pathProposal(repairer1, _, _, _));
    .abolish(closest(_, repairer1, _));
    +closest(none, repairer1, INF);
    
    .send(RepairerName, achieve, notifyRepairerFree);
    -gotoVertexRepair(_,_,_);
    
    !searchRepairerToHelp(repairer1, Pos).
    
+!repair_walk: 
    gotoVertexRepair(D, RepairerName, [H|T]) & position(MyV) & not ia.edge(MyV,H,_) & .my_name(MyName) & step(S)
<- 
    .print("Ops! REPAIR Wrong way to ",H, ". I'm going to select other goal to do.");
    
    .send(RepairerName, achieve, notifyRepairerFree);
    .abolish(gotoVertexRepair(_,_,_));
    -+hit(S);
    .send(repairer1, tell, hit(MyName, MyV));
    
    !select_goal.
    
+!repair_walk: 
    gotoVertexRepair(_, RepairerName, _) & not position(MyV) & step(S)
<- 
    .print("Ops! REPAIR Very wrong way to ",H, ". I'm going to select other goal to do.");
    
    .send(RepairerName, achieve, notifyRepairerFree);
    .abolish(gotoVertexRepair(_,_,_));
    -+hit(S);
    
    !select_goal.
    
+!repair_walk: 
    gotoVertexRepair(_, RepairerName, _) & not position(MyV)
<- 
    .print("Ops! REPAIR Very wrong way to ",H, ". I'm going to select other goal to do.");
    
    .send(RepairerName, achieve, notifyRepairerFree);
    .abolish(gotoVertexRepair(_,_,_));
    
    !select_goal.
    
+!repair_walk: 
    not gotoVertexRepair(_, RepairerName, _)
<- 
    .print("Ops! REPAIR Cancel my appointment. Very wrong way to ",H, ". I'm going to select other goal to do.");
    
    !select_goal.
    
+!newPositionRepairedGoal(V): 
    gotoVertexRepair(D, RepairerName, [V|[]])
<- 
    .print("REPAIR I arrived at ", V).
    
+!newPositionRepairedGoal(V):
    gotoVertexRepair(D, RepairerName, [V|T]) 
<- 
    -gotoVertexRepair(_, _, _);
    +gotoVertexRepair(D, RepairerName, T);
    .print("REPAIR I'm at ", V, ". My travel is: ", T).

+!newPositionRepairedGoal(V): true <- true.

+!reviewMyPositionRepaired([V|[]]): true <- true.
+!reviewMyPositionRepaired([V|T]):
    position(V) & gotoVertexRepair(D, RepairerName, _) 
<-
    -gotoVertexRepair(_, _, _);
    +gotoVertexRepair(D, RepairerName, T).
+!reviewMyPositionRepaired([V|T]):
    position(MyV) 
<-
    !reviewMyPositionRepaired(T).
+!reviewMyPositionRepaired:
    gotoVertexRepair(_, _, Route)
<-
    !reviewMyPositionRepaired(Route).
    
+!reviewMyPositionRepaired:
    true
<-
    !select_goal.
/* End walk repair */
   
/* Percept a new step */
+step(S):
    steps(S+1) | (lastStep(LastS) & LastS > S)
<- 
    .abolish(finishedOK);
    .print("Current step is the LAST ", S, " last was ", LastS);
    !calculateTotalSumVertices;
    //!recoverySystem(S, LastS);
    !testAgentNames;
    .abolish(lastStep(_));
    +lastStep(S);
    !newStepPreAction(S);
    .abolish(askedBuy); //I don't asked to buy in this step
    !select_goal;
    !finishSimulationLastStep;
    !!addLineLog(S).

+step(S):
    steps(S) & lastStep(LastS)
<- 
    .abolish(finishedOK);
    .print("Current step is the LAST ", S, " last was ", LastS);
    !calculateTotalSumVertices;
    //!recoverySystem(S, LastS);
    !testAgentNames;
    .abolish(lastStep(_));
    +lastStep(S);
    !newStepPreAction(S);
    .abolish(askedBuy); //I don't asked to buy in this step
    !select_goal;
    !!addLineLog(S).
    
+step(S):
    lastStep(LastS) 
<- 
    .abolish(finishedOK);
    .print("Current step is ", S, " last was ", LastS);
    !calculateTotalSumVertices;
    //!recoverySystem(S, LastS);
    !testAgentNames;
    .abolish(lastStep(_));
    +lastStep(S);
    !newStepPreAction(S);
    .abolish(askedBuy); //I don't asked to buy in this step
    !select_goal;
    !sendToken(S);
    !newStepPosAction(S);
    !!newStepPosActionParalel(S);
    !!addLineLog(S).
    
/* Percept a new step */
+step(S):
    true 
<- 
    .abolish(finishedOK);
    .print("Current step is ", S);
    !calculateTotalSumVertices;
    !testAgentNames;
    +lastStep(S);
    !newStepPreAction(S);
    .abolish(askedBuy); //I don't asked to buy in this step
    !select_goal;
    !sendToken(S);
    !newStepPosAction(S);
    !!newStepPosActionParalel(S);
    !!addLineLog(S).
    
+!clearFinishedOK(S):
    S > 10 & S < 50 & finishedOK
<-
    .abolish(finishedOK).
+!clearFinishedOK(S): true <- true.

+!heartbeat:
    position(Pos) & not stepsSamePosition(Pos, _) & step(S)
<-
    .abolish(stepsSamePosition(_, _));
    +stepsSamePosition(Pos, S).
+!heartbeat: true <- true.
    
/* Percepts Position */
@position1[atomic]  
+position(V):
    currentPosition(VOld) & step(S)
<-
    !broadcastVisit(V, S);
    ia.setVertexVisited(V, S);
    -myVisitedVertex(V, _);
    +myVisitedVertex(V, S);
    -+lastPosition(VOld);
    -+currentPosition(V);
    !newPosition(V).
    
@position2[atomic]  
+position(V):
    not (lastPosition(_) | currentPosition(_)) & step(S)
<-
    !broadcastVisit(V, S);
    ia.setVertexVisited(V, S);
    -myVisitedVertex(V, _);
    +myVisitedVertex(V, S);
    .abolish(lastPosition(_));
    +lastPosition(V);
    .abolish(currentPosition(_));
    +currentPosition(V);
    !newPosition(V).
    
+!broadcastVisit(V, S):
    not ia.visitedVertex(V, S)
<-
    .broadcast(tell,visitedVertex(V, S)).
+!broadcastVisit(V, S): true <- true.


/* Percepts Entity */
@visibleEntity1[atomic]
+visibleEntity(Entity, V, Team, Status):
    myNameInContest(Entity) & not myTeam(_)
<-
    +myTeam(Team).
    
@visibleEntity3[atomic]
+visibleEntity(Entity, V, Team, Status)[source(percept)]:
    step(S)
<-
    -lastSeenEntity(Entity, _);
    +lastSeenEntity(Entity, S);
    -entity(Entity, _, Team, _);
    +entity(Entity, V, Team, Status);
    !notifySaboteursAboutEnemy(Entity, V, Team, Status);
    !!processEntity(Entity);
    !!markCurrentOpponent(Team).
    
@visibleEntity4[atomic]
+visibleEntity(Entity, V, Team, Status)[source(percept)]:
    true
<-
    -entity(Entity, _, Team, _);
    +entity(Entity, V, Team, Status);
    !notifySaboteursAboutEnemy(Entity, V, Team, Status);
    !!processEntity(Entity);
    !!markCurrentOpponent(Team).
    
@visibleEntity5[atomic]
-visibleEntity(Entity, V, Team, Status)[source(percept)]:
    true
<-
    !unnotifySaboteursAboutEnemy(Entity, V, Team, Status);
    !!markCurrentOpponent(Team).
    
+!evaluateMyHealth(Health):
    not myLastHealth(_)
<-
    +myLastHealth(Health).
    
+!evaluateMyHealth(Health):
    myLastHealth(LastHealth) & LastHealth > Health & position(Pos) & myTeam(MyTeam)
<-
    for (visibleEntity(Entity, Pos, Team, normal) & MyTeam \== Team & not entityType(Entity, _) & not suspect(Entity)) {
        +suspect(Entity);
        .broadcast(tell, suspect(Entity));
        .print("Add suspect ", Entity);
    }
    -+myLastHealth(Health).
    
+!evaluateMyHealth(Health): true <- true.

+!evaluateHealthDie:
    step(S) & not lastDie(_)
<-
    .print("My new lastDie is ", S);
    +lastDie(S).

+!evaluateHealthDie:
    step(S)
<-
    .print("My new lastDie is ", S);
    -+lastDie(S).
    
+health(0):
    is_wait_repair_goal_general(_)
<-
    !evaluateMyHealth(0);
    !evaluateHealthDie.

+health(0):
    .my_name(repairer1) & position(Pos) & step(S) & not hit(_) & infinite(INF)
<-
    +hit(S);
    .abolish(hit(repairer1, _));
    +hit(repairer1, Pos);
    
    .print("repairer1 was hit at ", Pos);
    .abolish(pathProposal(repairer1, _, _, _));
    .abolish(closest(_, repairer1, _));
    +closest(none, repairer1, INF);
    
    !searchRepairerToHelp(repairer1, Pos);
    !evaluateMyHealth(0);
    !evaluateHealthDie.
    
+health(0):
    .my_name(MyName) & position(Pos) & step(S) & not hit(_)
<-
    +hit(S);
    .send(repairer1, tell, hit(MyName, Pos));
    !evaluateMyHealth(0);
    !evaluateHealthDie.

@health2[atomic]
+health(MyH):
    MyH > 0 & hit(_) & gotoVertexRepair(_, RepairerName,_)
<-
    .print("I'm cured! Notifying my repairer... ", RepairerName);
    .send(repairer1, tell, iWasRepaired);
    .send(RepairerName, achieve, notifyRepairerFree);
    .abolish(gotoVertexRepair(_,_,_));
    .abolish(hit(_));
    .abolish(waitABit);
    !evaluateMyHealth(MyH).
    
@health3[atomic]
+health(MyH):
    MyH > 0 & hit(_)
<-
    .print("I'm cured!");
    .send(repairer1, tell, iWasRepaired);
    .abolish(gotoVertexRepair(_,_,_));
    .abolish(hit(_));
    .abolish(waitABit);
    !evaluateMyHealth(MyH).
    
@health4[atomic]
+health(MyH):
    MyH > 0 & waitABit
<-
    .print("I'm cured!");
    .send(repairer1, tell, iWasRepaired);
    .abolish(gotoVertexRepair(_,_,_));
    .abolish(hit(_));
    .abolish(waitABit);
    !evaluateMyHealth(MyH).

+health(0):
    true
<-
    !evaluateMyHealth(0);
    !evaluateHealthDie.
    
+health(MyH):
    true
<-
    !evaluateMyHealth(MyH).
    
+!evaluateMaxHealth(MyH):
    not myMaxHealth(_)
<-
    +myMaxHealth(MyH).
    
+!evaluateMaxHealth(MyH):
    myMaxHealth(MyMaxH) & MyH > MyMaxH
<-
    -+myMaxHealth(MyH).
+!evaluateMaxHealth(MyH): true <- true.
    
+!testIHaveAppointmentButImCured:
    gotoVertexRepair(_,RepairerName,_) & health(MyH) & MyH > 0
<-
    .print("I'm cured! Notifying my repairer... ", RepairerName);
    .send(repairer1, tell, iWasRepaired);
    .send(RepairerName, achieve, notifyRepairerFree);
    -gotoVertexRepair(_,_,_);
    -hit(_).
+!testIHaveAppointmentButImCured: true <- true.
    
+!cancelAppointment:
    hit(_) & gotoVertexRepair(_, RepairerName,_)
<-
    .print("My repairer cancel the appointment... ", RepairerName);
    -gotoVertexRepair(_,_,_).
    
+!cancelAppointment:
    hit(_)
<-
    .print("My repairer cancel the appointment... ");
    -gotoVertexRepair(_,_,_).
    
+!cancelAppointment:
    health(0) & step(S) & not hit(_)
<-
    .print("My repairer cancel the appointment... ");
    +hit(S);
    -gotoVertexRepair(_,_,_).
    
+!cancelAppointment:
    true
<-
    .print("My repairer cancel the appointment... No problem.");
    -gotoVertexRepair(_,_,_).

+!gotoRepaired(D, Path)[source(RepairerName)]:
    health(MyH) & MyH > 0
<-
    .print("I'm cured before appointment! Notifying my repairer... ", RepairerName);
    .send(repairer1, tell, iWasRepaired);
    .send(RepairerName, achieve, notifyRepairerFree);
    .abolish(gotoVertexRepair(_,_,_));
    .abolish(hit(_));
    .abolish(waitABit).

+!gotoRepaired(D, Path)[source(RepairerName)]:
    currentPosition(MyV)
<-
    +gotoVertexRepair(D, RepairerName, Path);
    .print("I'm at ", MyV , " have to go to ", D).
    
+!achieveDestinationRepair: 
    gotoVertexRepair(_, _, [D|_]) & position(MyV)
<- 
    .print("I'm going to ",D, " to be repaired, because I'm at ", MyV);
    !goto(D).   
+!achieveDestinationRepair: true <- !select_goal.
    
+!waitRepair(V):
    position(V) & there_is_enemy_at(V)
<- 
    !init_goal(recharge).
    
+!waitRepair(V):
    position(MyV) & there_is_enemy_at(MyV)
<- 
    !goto(V).

+!waitRepair(V):
    true
<- 
    !init_goal(recharge).
    
+!newStepPreAction(S):
    waitingSince(SWait) & S - SWait >= 3
<-
    .abolish(waitABit);
    -waitingSince(_);
    !newStepPreAction(S).
    
+!newStepPreAction(S):
    health(0) & hit(StepHit) & not .number(StepHit)
<-
    .print("StepHit is not a number and I'm disabled.");
    .abolish(hit(_));
    +hit(S);
    !newStepPreAction(S).
    
+!newStepPreAction(S):
    hit(StepHit) & not .number(StepHit)
<-
    .print("StepHit is not a number and I'm not disabled.");
    .abolish(hit(_));
    !newStepPreAction(S).

+!newStepPreAction(S):
    .random(X) & hit(StepHit) & S - StepHit >= (X * 6) + 3 & not gotoVertexRepair(_,_,_) & .my_name(repairer1) & position(Pos) & infinite(INF)
<-
    .print("I'm waiting too much. I will try to notify the repairers again.");
    
    .abolish(hit(_));
    +hit(S);
    .abolish(hit(repairer1, _));
    +hit(repairer1, Pos);
    
    .abolish(pathProposal(repairer1, _, _, _));
    .abolish(closest(_, repairer1, _));
    +closest(none, repairer1, INF);
    
    !searchRepairerToHelp(repairer1, Pos).
    
+!newStepPreAction(S):
    .random(X) & hit(StepHit) & S - StepHit >= (X * 6) + 3 & not gotoVertexRepair(_,_,_) & .my_name(MyName) & position(Pos)
<-
    .print("I'm waiting too much. I will try to notify the repairers again.");
    -+hit(S);
    .send(repairer1, tell, hit(MyName, Pos)).
    
+!newStepPreAction(S):
    hit(StepHit) & S - StepHit >= 13 & gotoVertexRepair(_,RepairerName,_) & .my_name(repairer1) & position(Pos) & infinite(INF)
<-
    .print("I'm waiting too much. I will try to notify the repairers again.");
    
    .abolish(hit(_));
    +hit(S);
    .abolish(hit(repairer1, _));
    +hit(repairer1, Pos);
    
    .abolish(pathProposal(repairer1, _, _, _));
    .abolish(closest(_, repairer1, _));
    +closest(none, repairer1, INF);
    
    .send(RepairerName, achieve, notifyRepairerFree);
    -gotoVertexRepair(_,_,_);
    
    !searchRepairerToHelp(repairer1, Pos).
    
+!newStepPreAction(S):
    hit(StepHit) & S - StepHit >= 13 & gotoVertexRepair(_,RepairerName,_) & .my_name(MyName) & position(Pos)
<-
    .send(RepairerName, achieve, notifyRepairerFree);
    -gotoVertexRepair(_,_,_);
    .print("I'm waiting too much. I will try to notify the repairers again.");
    -+hit(S);
    .send(repairer1, tell, hit(MyName, Pos)).

+!newStepPreAction(S):
    true
<-
    !testIHaveAppointmentButImCured.
    
//Initialize the beliefs every time when the agent enter in the environment
@myName1[atomic]
+myNameInContest(MyName):
    not infinite(_)
<-
    .print("Recebi");
    +infinite(10000);
    +maxWeight(10);
    
    +costBattery(100);
    +costShield(100);
    +costSabotageDevice(100);
    +costSensor(100);
    
    +minEnergy(2); //2 is the safe minimum to allow the agent to execute actions
    +myNameInContest(MyName);
    !init;
    !loadAgentNames;
    !createToken.
    
+!recoverySystem(S, LastS):
    myNameInContest(MyName) & S < LastS
<- 
    .print("Recovery system started!");
    !resetSystem;
    +myNameInContest(MyName).
    
+!recoverySystem(S, LastS):
    S < LastS
<- 
    .print("Recovery system started without my name!");
    !resetSystem;
    .send(angel, achieve, tellMyName).

+!recoverySystem(S, LastS):
    not myNameInContest(MyName)
<- 
    .print("Recovery system started without my name two!");
    !resetSystem;
    .send(angel, achieve, tellMyName).
    
+!recoverySystem(S, LastS):
    true
<- 
    true.
    
+waitABit:
    not waitingSince(_) & step(S)
<-
    +waitingSince(S).

+!calculeShortestPath(S, D, PathX, LenghtX):
    true
<-
    ia.shortestPath(S, D, Path, Lenght);
    PathX = Path;
    LenghtX = Lenght;
    .print("The shortest path between ", S, " and ", D, " is ", PathX, " with lenght ", Lenght).
    
/* SWARM */
+swarmMode:
    true
<-
    .print("SWARM: swarm mode on").
    
+!gotoSwarmPlace:
    bestCoverageSwarm(V, Value, List) & currentPosition(S) //& list_vertex_by_value(Value, List)
<-
    .print("SWARM: Going to some best vertex! ", List);
    ia.shortestPathDijkstraComplete(S, List, D, Path, Lenght);
    .print("SWARM: Best vertex to go is ", S, " -> ", D, " with path: ", Path, " and lenght: ", Lenght);
    !prepareTogoSwarmPlace(Path, D).
    
    
-!gotoSwarmPlace:
    bestCoverageSwarm(V, Value, List) & currentPosition(S) & noMoreVertexToProbe
    & not (
            .my_name(explorer1) | .my_name(explorer2) | 
            .my_name(explorer3) | .my_name(explorer4) |
            .my_name(explorer5) | .my_name(explorer6)
          )
<-
    //.send(explorer1, achieve, calculeSomePathForMe(S, List));
    //.send(explorer2, achieve, calculeSomePathForMe(S, List));
    //.send(explorer3, achieve, calculeSomePathForMe(S, List));
    //.send(explorer4, achieve, calculeSomePathForMe(S, List));
    .print("SWARM: I do not know any way to go to best place!").
    
-!gotoSwarmPlace:
    true
<-
    .abolish(bestCoverageSwarm(_, _, _));
    .print("SWARM: I do not know any way to go to best place. Waiting...").
    
+!prepareTogoSwarmPlace(Path, PosAim):
    .list(Path) & currentPosition(S)
<-
    .abolish(pathTogoSwarm(_,_));
    +pathTogoSwarm(PosAim, Path);
    .print("SWARM: My choose is ", Path, " from ", S, " to achieve ", PosAim).
    
+!prepareTogoSwarmPlace(Path, PosAim):
    step(S)
<-
    .print("SWARM: My choose is wait and wait");
    .wait( { +step(S+2) }, 1000, _);
    .print("SWARM: I'm going again");
    !gotoSwarmPlace.
    
+!prepareTogoSwarmPlace(Path, PosAim):
    true
<-
    .print("SWARM: My choose is wait and wait (no step)");
    .wait( { +step(_) }, 100, _);
    !prepareTogoSwarmPlace(Path, PosAim).

+!setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood):
    currentPosition(Pos) & .member(Pos,Neighborhood)
<-
    .abolish(bestVertexArea(_));
    +bestVertexArea(BestVertex);
    .print("## NEW BEST COVERAGE received, but I'm at ", Pos , " Vertex: ", BestVertex, " Value: ", BestValue, " Neighborhood: ", Neighborhood);
    !ajustAllowedDistance.
    
+!setNewBestCoverageSwarm(BestVertex, BestValue, Neighborhood):
    true
<-
    .abolish(bestCoverageSwarm(_, _, _));
    .abolish(pathTogoSwarm(_, _));
    .abolish(bestVertexArea(_));
    +bestVertexArea(BestVertex);
    .print("## NEW BEST COVERAGE received! Vertex: ", BestVertex, " Value: ", BestValue, " Neighborhood: ", Neighborhood);
    +bestCoverageSwarm(BestVertex, BestValue, Neighborhood);
    !ajustAllowedDistance;
    !gotoSwarmPlace.
    

+!ajustAllowedDistance:
    step(S) & S < 50
<-
    !setAllowedDistance(1,0).
    
+!ajustAllowedDistance:
    step(S) & S < 8000
<-
    !setAllowedDistance(2,0).
    
+!ajustAllowedDistance:
    true
<-
    !setAllowedDistance(3,1).
    
+!newPositionSwarmGoal(V): 
    pathTogoSwarm(D, [V|[]])
<- 
    .print("SWARM GOING: I arrived at ", V).
    
+!newPositionSwarmGoal(V): 
    pathTogoSwarm(D, [V|T])
<- 
    -pathTogoSwarm(_, _);
    +pathTogoSwarm(D, T);
    .print("SWARM GOING: I'm at ", V, ". My travel is: ", T).
    
+!newPositionSwarmGoal(V): true <- true.

+!cancelSwarmTravel:
    true
<-
    .abolish(bestCoverageSwarm(_, _, _));
    .abolish(pathTogoSwarm(_, _)).
    
/* SWARM GOING */
+!walkSwarm: 
    pathTogoSwarm(D, [])
<- 
    .print("SWARM CURIOUS: I'm already at aim. Choosing another goal.");
    !select_goal.
    
+!walkSwarm: 
    pathTogoSwarm(D, [H|T]) & position(H)
<- 
    -pathTogoSwarm(_, _);
    +pathTogoSwarm(D, T);
    !walkSwarm.
    
+!walkSwarm: 
    pathTogoSwarm(D, [H|T]) & position(MyV) & ia.edge(MyV,H,_)
<- 
    .print("SWARM I'm going to vertex ", H);
    !goto(H).
    
+!walkSwarm: 
    pathTogoSwarm(D, [H|T]) & position(MyV) & not ia.edge(MyV,H,_)
<- 
    .print("Ops! SWARM Wrong way to ",H, ". I'm going to select other goal to do.");
    !cancelSwarmTravel;
    !select_goal.

+!walkSwarm:
    true
<-
    .print("SWARM, choosing another goal");
    !select_goal.
    
+!setAllowedDistance(DistanceOutside, DistanceInside):
    not allowedDistance(DistanceOutside,DistanceInside)
<-
    .print("New allowed distance setted to ", DistanceOutside, " and ", DistanceInside);
    -allowedDistance(_,_);
    +allowedDistance(DistanceOutside,DistanceInside).
+!setAllowedDistance(DistanceOutside, DistanceInside): true <- true.
    
+!calculeAllowedArea(DistanceOutside,DistanceInside):
    bestVertexArea(D)
<-
    ia.walkAreaSwarm(D, DistanceOutside, DistanceInside, NeighborhoodOutside, NeighborhoodInside);
    .print("SWARM WALKING INSIDE. I can walk inside of (border) ", NeighborhoodOutside, " or inside of  ", NeighborhoodInside);
    .abolish(allowedArea(_, _));
    +allowedArea(NeighborhoodOutside, NeighborhoodInside).
+!calculeAllowedArea(DistanceOutside,DistanceInside): true <- true.
-!calculeAllowedArea(DistanceOutside,DistanceInside): 
    true 
<- 
    .print("I do not know any vertex from the best area!").
    
+!newStepPosActionParalel(S):
    allowedDistance(DistanceOutside,DistanceInside)
<-
    !ajustAllowedDistance;
    !calculeAllowedArea(DistanceOutside,DistanceInside).
+!newStepPosActionParalel(S): true <- true.
/* END SWARM GOING */

+!synchronizeGraph:
    step(S) & lastSync(Last) & S - Last > 3
<-
    .print("Synchronizing...");
    -+lastSync(S);
    ia.synchronizeGraph.
    
+!synchronizeGraph:
    not lastSync(_)
<-
    +lastSync(0).
    
+!synchronizeGraph:
    true
<-
    true.

+!calculateTotalSumVertices:
    .my_name(explorer4) & ia.sumVertices(Total)
<-
    .print("Calculating the sum of all vertices: ", Total);
    !updateTotalSumVertices(Total);
    .broadcast(achieve, updateTotalSumVertices(Total)).
+!calculateTotalSumVertices: true <- true.

@updateTotalSumVerticesP[atomic]
+!updateTotalSumVertices(Total):
    true
<-
    .abolish(sumVertices(_));
    +sumVertices(Total).
    
+!walk_repair_forever_alone:
    get_vertex_to_go_repair_forever_alone(D, Path)
<-
    .print("I'm forever alone. I'm going to ", D, " using path: ", Path);
    !testWalkForeverAlone(D);
    !gotoPathAlone(Path).
    
+!walk_repair_forever_alone: 
    is_good_destination(Op) 
<- 
    .print("I'm forever alone. I do not know any path.");
    !goto(Op).

+!testWalkForeverAlone(D):
    visibleEntity(Entity, D, _, _) & friend(FriendName, Entity, repairer)
<-
    .print("I'm forever alone. I can see ", FriendName, " at ", D).
    
+!testWalkForeverAlone(D):
    true
<-
    .print("I'm forever alone. I do not see anyone at ", D).
    
+!gotoPathAlone([]):
    true
<-
    .print("I'm forever alone. I do not know any path and I'm lost.");
    !recharge.
    
+!gotoPathAlone([V|[]]):
    position(V)
<-
    .print("I'm forever alone. I do not know any path and I'm lost two.");
    !recharge.
    
+!gotoPathAlone([V|T]):
    position(V)
<-
    !gotoPathAlone(T).
    
+!gotoPathAlone([V|_]):
    true
<-
    .print("I'm forever alone. My next step is ", V);
    !goto(V).
    
+!notifySaboteursAboutEnemy(Entity, V, Team, normal):
    not myTeam(Team) & .my_name(MyName) & generalPriority(MyName, Id)
<-
    ia.addEnemyPosition(Id, Entity, V).
    
+!notifySaboteursAboutEnemy(Entity, V, Team, disabled):
    not myTeam(Team) & .my_name(MyName) & generalPriority(MyName, Id)
<-
    ia.remEnemyPosition(Id, Entity).
+!notifySaboteursAboutEnemy(_, _, _, _): true <- true.
    
+!unnotifySaboteursAboutEnemy(Entity, V, Team, normal):
    not myTeam(Team) & .my_name(MyName) & generalPriority(MyName, Id)
<-
    ia.remEnemyPosition(Id, Entity).
+!unnotifySaboteursAboutEnemy(_, _, _, _): true <- true.

//If I already know all saboteurs there are not suspects
+entityType(Entity, Type):
    .count((entityType(EntitySab, "Saboteur") & not friend(_, EntitySab, _)), N) & N >= 4
<-
    .abolish(suspect(_)).
    
+entityType(Entity, Type):
    true
<-
    .abolish(suspect(Entity)).
    
+!broadcastCurrentPosition(V):
    .my_name(MyName) & generalPriority(MyName, Id)
<-
    .print("Notifying my new position: ", V);
    ia.setAgentPosition(Id, V).
+!broadcastCurrentPosition(V).
    
+lastActionResult(failed_limit):
    true
<-
    .print("Limit buy!");
    +limitBuy.
    
+ranking(Rank):
    true
<-
    .send(coach, tell, ranking(Rank)).
    
+bye:
    true
<-
    .stopMAS.
    
/*
 * Plans to find the good are faster
 */ 
+!gotoPathFastSwarm([]):
    true
<-
    .print("I'm mode fast swarm on. I do not know any path and I'm lost.");
    !random_walk.
    
+!gotoPathFastSwarm([V|[]]):
    position(V)
<-
    .print("I'm mode fast swarm on. I do not know any path and I'm lost two.");
    !random_walk.
    
+!gotoPathFastSwarm([V|T]):
    position(V)
<-
    !gotoPathFastSwarm(T).
    
+!gotoPathFastSwarm([V|_]):
    true
<-
    .print("I'm mode fast swarm on. My next step is ", V);
    !goto(V).
    
/*
 * Plans to find a vertex outside of good area
 */ 
+!gotoPathOutsideGoodArea([]):
    true
<-
    .print("I'm mode inside good area going outside. I do not know any path and I'm lost.");
    !random_walk.
    
+!gotoPathOutsideGoodArea([V|[]]):
    position(V)
<-
    .print("I'm mode inside good area going outside. I do not know any path and I'm lost two.");
    !random_walk.
    
+!gotoPathOutsideGoodArea([V|T]):
    position(V)
<-
    !gotoPathOutsideGoodArea(T).
    
+!gotoPathOutsideGoodArea([V|_]):
    true
<-
    .print("I'm mode inside good area going outside. My next step is ", V);
    !goto(V).
    
/*
 * Plans to find a vertex outside of good area
 */
+!gotoPathOutsideGoodArea(D, Path):
    not lastMoveOutsideToInside(_)
<-
    +lastMoveOutsideToInside(D);
    !gotoPathOutsideGoodArea(Path). 
 
+!gotoPathOutsideGoodArea(D, Path):
    true
<-
    -+lastMoveOutsideToInside(D);
    !gotoPathOutsideGoodArea(Path).
    
+!gotoPathOutsideGoodArea([]):
    true
<-
    .print("I'm mode inside good area going outside. I do not know any path and I'm lost.");
    !random_walk.
    
+!gotoPathOutsideGoodArea([V|[]]):
    position(V)
<-
    .print("I'm mode inside good area going outside. I do not know any path and I'm lost two.");
    !random_walk.
    
+!gotoPathOutsideGoodArea([V|T]):
    position(V)
<-
    !gotoPathOutsideGoodArea(T).
    
+!gotoPathOutsideGoodArea([V|_]):
    true
<-
    .print("I'm mode inside good area going outside. My next step is ", V);
    !goto(V).


/*
 * Plans to find a vertex inside of good area
 */ 
+!gotoPathInsideGoodArea(D, Path):
    not lastMoveInsideToOutside(_)
<-
    +lastMoveInsideToOutside(D);
    !gotoPathInsideGoodArea(Path).  
 
+!gotoPathInsideGoodArea(D, Path):
    true
<-
    -+lastMoveInsideToOutside(D);
    !gotoPathInsideGoodArea(Path).
    
+!gotoPathInsideGoodArea([]):
    true
<-
    .print("I'm mode inside good area going inside. I do not know any path and I'm lost.");
    !random_walk.
    
+!gotoPathInsideGoodArea([V|[]]):
    position(V)
<-
    .print("I'm mode inside good area going inside. I do not know any path and I'm lost two.");
    !random_walk.
    
+!gotoPathInsideGoodArea([V|T]):
    position(V)
<-
    !gotoPathInsideGoodArea(T).
    
+!gotoPathInsideGoodArea([V|_]):
    true
<-
    .print("I'm mode inside good area going inside. My next step is ", V);
    !goto(V).
    
+!evaluateInsideArea:
    myTeam(MyTeam) & is_at_swarm_position_test & lastMoveInsideToOutside(V) & (not is_inside_team_friends | ia.vertex(V, MyTeam))
<-
    -lastMoveInsideToOutside(_).
    
+!evaluateInsideArea: true <- true.

+!sendToken(S):
    token(K) & K <= S & get_next_agent_token(NextAgent)
<-
    .abolish(token(_));
    .send(NextAgent, tell, token(S+1));
    .print("Sent token to ", NextAgent).
+!sendToken(S): true <- true.

+!forwardToken(S):
    token(_) & get_next_agent_token(NextAgent)
<-
    .abolish(token(_));
    .send(NextAgent, tell, token(S));
    .print("Forwarding token to ", NextAgent).
+!sendToken(S): true <- true.

+token(S):
    (is_disabled | not noMoreVertexToProbe | not is_at_swarm_position)
    & not lastToken(S)
<-
    .abolish(lastToken(_));
    +lastToken(S);
    !forwardToken(S);
    .print("Received token to step ", S, " but forwarding it").
    
+token(S):
    (is_disabled | not noMoreVertexToProbe) 
<-
    .abolish(lastToken(_));
    +lastToken(S);
    !forwardToken(S);
    .print("Received token to step ", S, " again but forwarding it").
    
+token(S):
    lastToken(S)
<-
    .print("Received token to step ", S, " I need to forward it, but I received it again!").

+token(S):
    true
<-
    .abolish(lastToken(_));
    +lastToken(S);
    .print("Received token to step ", S).
    
+!createToken:
    .my_name(MyName) & generalPriority(MyName, 1)
<-
    +token(0);
    .print("Created token").
+!createToken: true <- true.

+!addLineLog(S):
    lastActionResult(Result) & lastAction(LastAction) & .my_name(MyName) & generalPriority(MyName, AgentId) & myTeam(MyTeam)
<-
    ia.addLastAction(MyTeam, AgentId, S, LastAction, Result).
+!addLineLog(S):
    .my_name(MyName) & generalPriority(MyName, AgentId) & myTeam(MyTeam)
<-
    ia.addLastAction(MyTeam, AgentId, S, error, error).
+!addLineLog(S): true <- true.
    
+!markCurrentOpponent(Team):
    not myTeam(Team)
<-
    +opponent(Team).
+!markCurrentOpponent(Team): true <- true.
    
+!notifyCoachSimEnd:
    opponent(Team)
<-
    .send(coach, achieve, setSimEnd(Team));
    .send(coach, tell, simEnd).

+maxHealth(MyH):
    true
<-
    !evaluateMaxHealth(MyH).
