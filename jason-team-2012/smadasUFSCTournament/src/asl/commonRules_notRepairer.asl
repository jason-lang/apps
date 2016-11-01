//If I'm disabled and there is a repairer at the same vertex, so I'm going to wait
is_wait_repair_goal(MyV) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) & 
               visibleEntity(Entity, MyV, MyTeam, _) & friend(_, Entity, repairer) & Entity \== MyName.

//If I'm disabled and there is a repairer at some adjacent vertex, so I'm going to wait
is_wait_repair_goal(V) :- is_disabled & position(MyV) & myTeam(MyTeam) & myNameInContest(MyName) &
               ia.edge(MyV,V,_) & visibleEntity(Entity, V, MyTeam, _) & friend(_, Entity, repairer) & Entity \== MyName.
               
