/*
 * If I'm at some vertex with an enemy saboteur, so I count how many friends are there too.
 * I choose to leave or to parry using probability.
 * The probability to execute parry is: 1.0 / N, where N is the amount of friends
 */ 
is_parry_goal :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) &
         Team \== MyTeam & (entityType(Entity, "Saboteur") | is_suspect(Entity)) &
         there_is_more_enemies_than_friends(MyV) &
         .count(visibleEntity(_, MyV, MyTeam, normal), N) &
         .random(K) & K <= (1.0 / N).

is_parry_goal_strong :- position(MyV) & myTeam(MyTeam) & visibleEntity(Entity, MyV, Team, normal) &
         Team \== MyTeam & entityType(Entity, "Saboteur") &
         there_is_more_enemies_than_friends(MyV) &
         .count(visibleEntity(_, MyV, MyTeam, normal), N) &
         .random(K) & K <= (1.0 / N).

there_is_more_enemies_than_friends(V) :-
                            myTeam(MyTeam) &
                            .count((visibleEntity(Entity, V, MyTeam, normal) & friend(_, Entity, saboteur)), NFriend) &
                            .count((visibleEntity(EntityEnemy, V, Team, normal) & Team \== MyTeam & (entityType(EntityEnemy, "Saboteur") | is_suspect(EntityEnemy))), NEnemy) &
                            NEnemy > NFriend.
