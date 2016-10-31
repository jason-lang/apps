/*
   -- plans for passing a fence 
*/

need_cross_fence(Sch,FX,FY) :-     // used by exploration group 
    scheme(explore_sch,Sch) & 
    target(TX,TY) & 
    not jia.corral(TX,TY) & 
    pos(MX, MY, _) & 
    jia.has_object_in_path(MX, MY, TX, TY, closed_fence, FX, FY, Dist) &
    .print("fff I have a fence in my path at ",Dist," steps") &
    jia.fence_switch(FX, FY, SX, SY) & not jia.is_corral_switch(SX,SY) & // in case I need to pass through the corral to achieve my target
    Dist < 10.
need_cross_fence(Sch,FX,FY) :-    // used by herding group 
    scheme(herd_sch,Sch) &
    has_boy_beyond_fence(FX,FY).
    
boy_beyond_fence(BX,BY,FX,FY) :- 
    corral_center(TX,TY) & 
    jia.has_object_in_path(BX, BY, TX, TY, closed_fence, FX, FY, Dist) &
    jia.fence_switch(FX, FY, SX, SY) &
    not jia.is_corral_switch(SX,SY) &
    .print("fff I have a fence ",FX,",",FY," in my path to corral at ",Dist," steps") &
    Dist < 15.

/*
porter_candidates(CurSch, Gr, Cand) :-  // candidates in the case of exploring
   scheme(explore_sch,CurSch) & 
   .findall(P, play(P,_,Gr), Cand) & 
   .length(Cand,N) & N > 1.             // at least 2 players to start the scheme
porter_candidates(CurSch, Gr, Cand) :-  // candidates in the case of herding
   scheme(herd_sch,CurSch)[owner(O)] & 
   .findall(P, play(P,_,Gr) & P \== O, Cand) & // do not consider owner of the group, the leader 
   .length(Cand,N) & N > 1.             // at least 3 players to start the scheme
*/   
can_play_porter(CurSch,P) :-  scheme(herd_sch,   CurSch) & play(P,herdboy,_). // only herdboys can go to pass fence // [owner(O)] & P \== O. 
can_play_porter(CurSch,_) :-  scheme(explore_sch,CurSch). 
   
all_passed([]) :- true.
all_passed([Ag|Others]) :-
   ally_pos(Ag,AX,AY) &
   //jia.path_length(AX,AY,SX,SY,_,fences) &
   goal_state(_,pass_fence(FX,FY,_,Direction),_) &
   pos(MeX,MeY,_) &
   same_side(FX,FY,MeX,MeY,AX,AY) &
   //( is_horizontal(FX,FY)  & .print("fff ",FX,FY," is horizontal") & AY * Direction > (FY * Direction) | 
   //  is_vertical(FX,FY)    & .print("fff ",FX,FY," is vertical")   & AX * Direction > (FX * Direction)) &
   .print("fff ",Ag," passed, it is at ",AX,",",AY," should pass fence ",FX,",",FY,", direction is ",Direction) &
   all_passed(Others).

// checks wheher A and O are in the same side of fence F
same_side(FX,FY,AX,_,OX,_) :- is_vertical(FX,FY)     & AX > FX & OX > FX.
same_side(FX,FY,AX,_,OX,_) :- is_vertical(FX,FY)     & AX < FX & OX < FX.
same_side(FX,FY,_,AY,_,OY) :- is_horizontal(FX,FY)   & AY > FY & OY > FY.
same_side(FX,FY,_,AY,_,OY) :- is_horizontal(FX,FY)   & AY < FY & OY < FY.

/*
no_cowboy_in_fence :-
   goal_state(_,pass_fence(FX,FY,_,_),_) &   
   not (ally_pos(Ag1,FX,AY) & jia.fence(FX,AY) & .print("fff ",Ag1," is in the fence!")) &
   not (ally_pos(Ag2,AX,FY) & jia.fence(AX,FY) & .print("fff ",Ag2," is in the fence!")). 
*/

is_horizontal(FX,FY) :- jia.fence(FX+1,FY) | jia.fence(FX-1,FY).
is_vertical(FX,FY)   :- jia.fence(FX,FY+1) | jia.fence(FX,FY-1).

{ begin maintenance_goal("+pos(_,_,_)") }

+!start_pass_fence[scheme(Sch),mission(Mission), group(Gr), role(Role)]
   : need_cross_fence(Sch, FX, FY) &
     jia.fence_switch(FX, FY, SX, SY)
  <- if (pass_fence_scheme(OtherSch,SX,SY,GK1) & scheme(pass_fence_sch,OtherSch)) { // if an active scheme for the same switch exists...
        !join_pass_fence_scheme(OtherSch,GK1)
     }{
        !create_pass_fence_scheme(Sch, Gr, SX, SY, FX, FY)
     }.  
     /*
     .my_name(Me);
     .findall(PFSch, scheme(pass_fence_sch,PFSch), PFSchs); // [owner(Oag)] & Oag \== Me
     !find_pass_fence_scheme(PFSchs, SX, SY, OtherSch, Porter2);
     .print("fff pass_fence porter2 ",OtherSch," from candidates ",PFSchs);
     if (OtherSch == no_scheme) {
        !create_pass_fence_scheme(Sch, Gr, SX, SY, FX, FY)
     }{
        !join_pass_fence_scheme(OtherSch,Porter2)
     }.*/  

+!start_pass_fence[scheme(Sch),mission(Mission), group(Gr), role(Role)]
   : need_cross_fence(Sch, FX, FY) &
     not jia.fence_switch(FX, FY, _, _)
  <- .print("fff I need to discover where the switch is");
     !fence_as_obstacle(15).
     
+!start_pass_fence[scheme(Sch),mission(Mission),group(Gr),role(Role)].
     
{ end }  

/*
+!find_pass_fence_scheme([],SX,SY,no_scheme,no_porter).
+!find_pass_fence_scheme([Sch|Others], SX,SY, PassSch, Porter2)
   : scheme(_,Sch)[owner(Oag)]
  <- .print("fff asking fence switch for ",Oag);
     .send(Oag, askOne, goal_state(Sch,pass_fence(SX,SY,_,_),_), Ans); 
     .print("fff answer is ",Ans);
     if (Ans == false) {
        //.print("fff try others ",Others);
        !find_pass_fence_scheme(Others,SX,SY,YYYY,XXXX);
        PassSch = YYYY;
        Porter2 = XXXX //; .print("fff return form ",Porter2) // TODO: fix this bug in Jason
     }{
        .print("fff asking porter ");
        .send(Oag, askOne, play(_,gatekeeper2,_), play(Porter2,_,_));
        PassSch = Sch //; .print("fff which is ",Porter2)
     }.
*/
  
+!create_pass_fence_scheme(CurSch, Gr, SX, SY, FX, FY)
//   : porter_candidates(CurSch, Gr, Cand1)
   : .findall(P, play(P,_,Gr) & can_play_porter(CurSch, P), Cand1) & 
     .length(Cand1) > 1             // at least 2 players to start the scheme
  <- ?pos(MyX,MyY,_);
     jia.switch_places(SX,SY,MyX,MyY,P1X,P1Y,P2X,P2Y);
     .print("fff places for switch ",SX,",",SY," are ",P1X,",",P1Y," and ",P2X,",",P2Y," Cand1=",Cand1);
  
     !find_closest(Cand1,pos(P1X,P1Y),HA1);
     .findall(P, play(P,_,Gr) & P \== HA1 & can_play_porter(CurSch,P), Cand2);
     !find_closest(Cand2,pos(P2X, P2Y),HA2);
     .print("fff near 1 is ",HA1, " near 2 is ",HA2);
     
     jmoise.create_scheme(pass_fence_sch, SchId);
     .print("fff Created pass fence scheme ", SchId); 
     +pass_fence_scheme(SchId,SX,SY,HA2)[scheme(SchId)];
     .broadcast(tell, pass_fence_scheme(SchId,SX,SY,HA2)[scheme(SchId)]);
     
     // set ID of fence based on switch
     jmoise.set_goal_arg(SchId,pass_fence,"X",SX); 
     jmoise.set_goal_arg(SchId,pass_fence,"Y",SY);
     
     ?scheme(SchType,CurSch);
     jmoise.set_goal_arg(SchId,pass_fence,"NextScheme",SchType);
     if (is_horizontal(FX,FY)) {
         if (FY > MyY) { // fence below
            jmoise.set_goal_arg(SchId,pass_fence,"Direction",1)
         }{
            jmoise.set_goal_arg(SchId,pass_fence,"Direction",-1)
         }
     }{
         if (FX > MyX) { // fence rigth
            jmoise.set_goal_arg(SchId,pass_fence,"Direction",1)
         }{
            jmoise.set_goal_arg(SchId,pass_fence,"Direction",-1)
         }
     };
     jmoise.set_goal_arg(SchId,goto_switch1,"X",P1X);
     jmoise.set_goal_arg(SchId,goto_switch1,"Y",P1Y);
     jmoise.set_goal_arg(SchId,goto_switch2,"X",P2X);
     jmoise.set_goal_arg(SchId,goto_switch2,"Y",P2Y);
     jmoise.add_responsible_group(SchId, Gr); // after seting parameters, so that the goal will be correctly generated
     
     .send(HA1, achieve, change_role(gatekeeper1, Gr));
     .send(HA2, achieve, change_role(gatekeeper2, Gr));
     if (SchType == explore_sch) {
         .print("fff stopping current scheme ",CurSch);
         jmoise.remove_scheme(CurSch) // should be the last thing, since this goal will be dropped due to the end of the scheme
     }.
     
     
+!create_pass_fence_scheme(CurSch, Gr, SX, SY, FX, FY)
  <- .print("fff ** I cannot create a pass fence scheme since I do not have enough partners!"). //;  !quit_all_missions_roles.

+!join_pass_fence_scheme(PassSch,_)
   : .my_name(Me) & scheme(_,PassSch)[owner(Me)]
  <- .print("fff I do not need to join the scheme created by me").
+!join_pass_fence_scheme(PassSch,Porter2)
  <- .print("fff join scheme ",PassSch," where porter is ",Porter2);
     ?my_group_players(Mates,_);
     .send(Porter2, tell, wait_to_pass(PassSch,Mates)).

+wait_to_pass(Sch,Mates)
   : goal_state(Sch,wait_others_pass(L),_)
  <- .print("fff changing agents to wait to pass to ",L,"+",Mates);
     .union(L,Mates,NewL);
     jmoise.set_goal_arg(Sch,wait_others_pass,"Others",NewL);
     !!clean_others(Sch,15). // wait for 20 steps

+!clean_others(Sch,N)
   : goal_state(_,wait_others_pass(Others),_) & N > 0
  <- .findall(Ag, .member(Ag,Others) & ally_pos(Ag,X,Y) & jia.fence(X,Y), InFence);
     .difference(Others, InFence, NewO);
     .wait( { +pos(_,_,_) }, 2000, _); // remove only in the next step, when they moved from the fence
     .print("fff removing ",InFence," from others ",Others," remain ",NewO);
     jmoise.set_goal_arg(Sch,wait_others_pass,"Others",NewO);
     !!clean_others(Sch,N-1).
+!clean_others(Sch,0)
  <- .print("fff removing all waiters");
     jmoise.set_goal_arg(Sch,wait_others_pass,"Others",[]).
+!clean_others(Sch,_) // no goal, ok, finish
  <- .print("fff stoping clean others");
     .abolish( wait_to_pass(Sch,_) ). // just clean messages

+!goto_switch(X,Y,Sch,Goal)
   : pos(X,Y,_) 
  <- .print("fff I am at switch ",X,",",Y," -- ",Goal);
     jmoise.set_goal_state(Sch,Goal,satisfied).
+!goto_switch(X,Y,Sch,goto_switch1)   // particular case: the GP1 needs to go to S1, but GP2 is already in S2, so no need to go to S1
   : not pos(X,Y,_) &
     goal_state(Sch, goto_switch2, achieved)
  <- .print("fff I do not need to go to switch ",X,",",Y," anymore -- ",Goal);
     jmoise.set_goal_state(Sch,Goal,satisfied).
+!goto_switch(X,Y,Sch,Goal)
   : not pos(X,Y,_)
  <- .print("yyyy going to switch ",X,",",Y," -- ",Goal);
     -+target(X,Y);
     .wait({ +pos(_,_,_) } );
     !goto_switch(X,Y,Sch,Goal).
        

+!goto_switch1(X,Y)[scheme(Sch)]
  <- !goto_switch(X,Y,Sch,goto_switch1).

+!goto_switch2(X,Y)[scheme(Sch)]
  <- !goto_switch(X,Y,Sch,goto_switch2).


+!wait_gatekeeper2[scheme(Sch),mission(Mission), group(Gr), role(Role)]
   : goal_state(Sch, goto_switch2(_,_), achieved) // it is already there
  <- .print("fff gatekeeper2 is there"); 
     jmoise.set_goal_state(Sch,wait_gatekeeper2,satisfied).
//+!wait_gatekeeper2[scheme(Sch),mission(Mission), group(Gr), role(Role)]
//   : play(GP2,gatekeeper2,Gr) &
//     goal_state(Sch, goto_switch2(S2X,S2Y), _) &
//     ally_pos(GP2,S2X,S2Y)
//  <- .print("fff gatekeeper2 passed"); 
//     jmoise.set_goal_state(Sch,wait_gatekeeper2,satisfied).     
+!wait_gatekeeper2[scheme(Sch),mission(Mission),group(Gr),role(Role)]
  <- .wait( { +pos(_,_,_) } );
     !!wait_gatekeeper2[scheme(Sch),mission(Mission),group(Gr),role(Role)].


+!cross_fence[scheme(Sch), group(Gr)]
   : group(exploration_grp,Gr)
  <- ?goal_state(Sch,pass_fence(FX,FY,_,_),_);
     .print("fff I should pass the fence ",FX,",",FY);
     jia.other_side_fence(FX,FY,TX,TY);
     .print("fff the new target is ",TX,",",TY);
     -+target(TX,TY);
     .wait({ +pos(TX,TY,_) } ).
+!cross_fence[scheme(Sch), group(Gr)]
   : group(herding_grp,Gr)
  <- // just go back to herdboy
    .print("fff I should go back to herdboy");
    jmoise.remove_role(gatekeeper1,Gr);
    !play_role(herdboy,Gr).

     
{ begin maintenance_goal("+pos(_,_,_)") }
  
+!wait_others_pass(_)[scheme(Sch),mission(Mission),group(Gr),role(Role)]
   : goal_state(Sch,wait_others_pass(Others),ready) & // should not use the parameter of the event, since it changes
     .my_name(Me) & .findall(P, play(P,_,Gr) & P \== Me, Mates) & // I need to wait all other members of my group, but me
     .print("fff I should wait ",Mates," and ",Others) &
     Others == [] &
     all_passed(Mates) // & no_cowboy_in_fence
  <- .print("fff all passed");
     jmoise.set_goal_state(Sch,wait_others_pass,satisfied);
     
     .print("fff removing the scheme ",Sch," since all agentes has passed");
     -pass_fence_scheme(Sch,SX,SY,GK2);
     .broadcast(untell, pass_fence_scheme(Sch,SX,SY,GK2));
     jmoise.set_goal_arg(Sch,pass_fence,"X",-1); // just to avoid others to think a scheme for a fence exists 
     jmoise.set_goal_arg(Sch,pass_fence,"Y",-1);
     !!remove_scheme_next_cicles(Sch);

     // if I am the poter1 (the last to pass), I need to finish it all
     // and restart team mates
     ?goal_state(Sch,pass_fence(_,_,NextSch,_),_);
     if (NextSch == explore_sch) {
        if (play(GP1, gatekeeper1, Gr)) {     
           .print("fff asking ",GP1," to stop playing gatekeeper1");
           .send(GP1, achieve, quit_all_missions_roles);
           .wait(1000); // wait GP1 to quit
           .send(GP1, achieve, create_exploration_gr)
        };
        // remove my own gatekeeper role (so that I can accept the ask scouter that will be send by the partner)
        jmoise.remove_role(Role,Gr);
        !!create_exploration_gr
     }{
        if (play(GP1, gatekeeper1, Gr)) {     
           .print("fff asking porters ",GP1," and myself to get back their herdboy roles");
           .send(GP1, achieve, change_role(herdboy, Gr))
        };
        !!change_role(herdboy, Gr)
     }.
//       jmoise.remove_scheme(Sch). // must be the last thing (since the deletion of the scheme cause the drop of this goal)
     
+!wait_others_pass(_)[scheme(Sch),mission(Mission),group(Gr),role(Role)]
  <- !check_conflict_pass_fence(Sch).

{ end }  

+!check_conflict_pass_fence(Sch)
      // in case we have two schemes for the same fence, abort one
  <- .my_name(Me);
     ?goal_state(Sch,pass_fence(SX,SY,_,_),_);
     .findall(PFSch, scheme(pass_fence_sch,PFSch)[owner(OS)] & PFSch \== Sch & OS < Me, PFSchs);
     !find_pass_fence_scheme(PFSchs, SX, SY, OtherSch, _);
     if (OtherSch \== no_scheme) {
         .print("fff ** conflict, two pass fence schemes for the same fence, aborting ",Sch);
         jmoise.remove_scheme(Sch)
     }.
+!check_conflict_pass_fence(_).
-!check_conflict_pass_fence(_).

+!restart_fence_case
   : .my_name(Me) & scheme(pass_fence_sch,Sch) & commitment(Me,_,Sch)
  <- .print("fff restart pass fence, removing the scheme and roles!");
     .findall(P, commitment(P,_,Sch), Players);
     jmoise.remove_scheme(Sch);
     // and restart team mates
    .send(Players, achieve, quit_all_missions_roles);
    .wait(1000); // wait them to quit
    .send(Players, achieve, create_exploration_gr).
     
+!restart_fence_case
  <- .print("fff restart pass fence, setting fence as obstacle for moving.");
     !fence_as_obstacle(5).
