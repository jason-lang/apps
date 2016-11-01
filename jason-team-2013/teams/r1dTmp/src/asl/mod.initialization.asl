!start.

+!start: .my_name(MyName) <- 
	!loadAgentNames;
	?friend(MyName, MyNameContest, _, _);
	!initNewRound;
	+myNameInContest(MyNameContest).
	
+!initNewRound:
	true
<-
    +infinite(10000);
    +maxWeight(10);
    
    +costBattery(100);
    +costShield(100);
    +costSabotageDevice(100);
    +costSensor(100);
    
    +minEnergy(2).