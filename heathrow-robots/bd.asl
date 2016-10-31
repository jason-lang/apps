skill(pasticBomb).
skill(bioBomb).
~skill(nuclearBomb).

safe_area(field1).

// received a message about a new bomb.
+bomb(RN, BombType) : skill(BombType)
   <- ?unattended_luggage(Terminal,Gate,RN);
      !go(Terminal, Gate);
      !check_if_safe_to_disarm(RN,BombType);
      !attempt_disarm(RN,BombType).

+bomb(RN, BombType) : ~skill(BombType)
   <- .broadcast(tell,security_alert).

+bomb(RN, BombType) : not skill(BombType) & not ~skill(BombType)
   <- .send(security_manager, tell, unkown_bomb_type(RN,BombType)).

+!attempt_disarm(RN,BombType) : safe_to_disarm(RN)
   <- !disarm(BombType).

+!attempt_disarm(RN,BombType) : not safe_to_disarm(RN)
   <- !move_to_safe_area(RN).

+!move_to_safe_area(RN) : true
   <- ?safe_area(Place);
      !discoverFreeCPH(FreeCPH);
      .send(FreeCPH, achieve, carryToSafePlace(RN,Place)).

// temporary plans, not implemented

+!go(T,G) : true <- true.
+!go(P)   : true <- true.

+!discoverFreeCPH(cph1) : true <- true.

+!check_if_safe_to_disarm(RN,BombType) : true <- true. // +safe_to_disarm(RN).

+!disarm(plasticBomb) : true <- true.
+!disarm(bioBomb) : true <- true.
+!disarm(dirtyBomb) : true <- true.
