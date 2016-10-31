/* -- plans for exploration phase -- */


/*
   -- plans for new match 
   -- create the initial exploration groups and areas 
*/


+gsize(_,_)                             // new match has started 
  <- !define_areas;
     !create_exploration_gr.

/*+!define_areas
  <- ?gsize(W,H);
     X = math.round(((W*H)/3)/H);
     +group_area(0, area(0,   0,       X,   H-1));
     +group_area(1, area(X+1, 0,       W-1, H/2));
     +group_area(2, area(X+1, (H/2)+1, W-1, H-1)).
*/

+!define_areas
 <- ?gsize(W,H);
    Lm = math.round(11*W/40);
    Hm = math.round(11*H/40);
    +group_area(0, area(0   , 0  ,Lm-1  ,H-Hm-1));
    +group_area(1, area(Lm  , 0  ,W-1   ,Hm-1  ));
    +group_area(2, area(Lm  ,Hm  ,W-Lm-1,H-Hm-1));
    +group_area(3, area(0   ,H-Hm,W-Lm-1,H-1   ));
    +group_area(4, area(W-Lm,Hm  ,W-1 ,H-1     )).
 
+!create_exploration_gr
   : .my_name(Me) &
     agent_id(Me,AgId) &
     AgId mod 2 == 1 &          // I have an odd Id and thus have to create a exploring group
     not .intend(create_exploration_gr)
  <- // create the team, if necessary
     if( Me == gaucho1 & not group(team,_) ) {
         jmoise.create_group(team) 
     };

     // create the exploration group
     if( not group(exploration_grp,_)[owner(Me)] ) {
        ?group(team,TeamGroup); // get the team Id
        jmoise.create_group(exploration_grp,TeamGroup,G);
        .print("ooo Exploration group ",G," created")
     } {
        ?group(exploration_grp,G)[owner(Me)]
     };
     
     // adopt role explorer in the group
     !change_role(explorer,G);
     
     // create the scheme
     if ( not (scheme(explore_sch,S) & scheme_group(S,G)) ) {
        .print("creating exploration scheme for group ",G);
        -target(_,_); // revome target so that a new one is selected by near unvisited
        jmoise.create_scheme(explore_sch, [G])  
     }.
     
+!create_exploration_gr.
          
// If I stop playing explorer, destroy the explore scheme/group I've created
-play(Me,explorer,G)
   : .my_name(Me)
  <- for( scheme(explore_sch,S)[owner(Me)] ) {
        .print("ooo Removing scheme ",S);
        jmoise.remove_scheme(S);
        .wait(1000)
     }. /* -- breaks pass-fence scheme
     for( group(exploration_grp,G)[owner(Me)] & not scheme_group(_,G)) {
        .print("ooo Removing group ",G," since I am not in the group anymore");
        jmoise.remove_group(G);
        .wait(1000)
     }. */

     
     
/* -- plans for the goals of role explorer -- */

{ begin maintenance_goal("+pos(_,_,_)") }

+!find_scouter[scheme(Sch),group(G)]
   : play(Ag,scouter,G)
  <- // if I can not reach my scouter anymore
     if (ally_pos(Ag,X,Y) & pos(MyX, MyY, _) & not jia.path_length(MyX, MyY, X, Y, _, fences) ) {
        .print("fff asking agent ",Ag," to quite its scouter role because I cannot reach it anymore");
        .send(Ag,achieve,quit_all_missions_roles);
        .wait(1000);
        .send(Ag,achieve,restart)
     }.

+!find_scouter[scheme(Sch),group(G)]
   : not play(_,scouter,G)
  <- .print("ooo Recruiting scouters for my explorer group ",G);
  
     ?pos(MyX,MyY,_); // wait my pos
     ?team_size(TS);
     
     // wait others pos
     while( .count(ally_pos(_,_,_), N) & N < (TS-1) ) {
        .print("ooo waiting others' location, I received ",N," locations until now");
        .wait({+ally_pos(_,_,_)}, 500, _)
     };
     
     // find distance to even agents
     .findall(ag_d(D,AgName),
              ally_pos(AgName,X,Y) & agent_id(AgName,Id) & Id mod 2 == 0 & jia.path_length(MyX, MyY, X, Y, D, fences),
              LOdd);
     .sort(LOdd, LSOdd);
     .print("ooo scouters candidates are ",LSOdd);
     !find_scouter(LSOdd,G);
     jmoise.set_goal_state(Sch, find_scouter, satisfied).

+!find_scouter[scheme(Sch),group(G)].
  
{ end }

+!find_scouter([],G)
  <- .print("ooo no scouter for me!").
+!find_scouter([ag_d(_,AgName)|_],GId)
  <- .print("ooo Ask ",AgName," to play scouter");
     .send(AgName, achieve, play_role(scouter,GId));
     .wait({+play(AgName,scouter,GId)},3000).  
-!find_scouter([_|LSOdd],GId) // in case the wait fails, try next agent
  <- .print("ooo find_scouter failure, try another agent from ",LSOdd);
     !find_scouter(LSOdd,GId).  

     
{ begin maintenance_goal("+pos(_,_,_)") } // old is +at_target

+!goto_near_unvisited[scheme(Sch),mission(Mission)]
   : not target(_,_)
     | (target(X,Y) & pos(X,Y,_)) // I am there
     | (target(X,Y) & (jia.obstacle(X,Y) | jia.fence(X,Y))) // I discovered that the target is a fence or obstacle
  <- .print("ooo I should find the nearest unvisited location and go there!");
     .my_name(Me); 
     ?agent_id(Me,MyId);
     ?group_area(MyId div 2, Area);  // get the area of my group
     ?pos(MeX, MeY, _);              // get my location
     jia.near_least_visited(MeX, MeY, Area, TargetX, TargetY);
     .print("ooo The nearest unvisited location is ",TargetX,",",TargetY);
     -+target(TargetX, TargetY).

+!goto_near_unvisited[scheme(Sch),mission(Mission)].
     /* added by the pattern
     .wait({+at_target}).
     !!goto_near_unvisited[scheme(Sch),mission(Mission)]
     */
     
{ end }

/* added by the pattern
-!goto_near_unvisited[scheme(Sch),mission(Mission)]
  <- .current_intention(I);
     .print("ooo Failure to goto_near_unvisited ",I);
     .wait({+pos(_,_,_)}); // wait next cycle
     !!goto_near_unvisited[scheme(Sch),mission(Mission)].
*/  

/* -- change to herding -- */

{ begin maintenance_goal("+pos(_,_,_)") }

+!change_to_herding[scheme(Sch),mission(Mission),group(Gr)]
   : cow(_,_,_) & .my_name(Me) & 
     jia.cluster(_,MyCows) &
     .length(MyCows) > 2
  <- .print("ooo I see some cows, create the herding group");
     // check whether the seen cows are being herded by other group
     .findall(L, group_leader(_,L) & L \== Me,Leaders);
     !ask_all_cows(Leaders,LCows);
     .intersection(MyCows, LCows, Common);
     .print("TTT all cows in herding groups are ",LCows," mine are ",MyCows," intersection is ",Common);
     if ( Common == [] ) {
        .findall(Scouter,play(Scouter,scouter,Gr),LScouters);
        !!create_herding_gr(LScouters);
        .print("ooo Removing group ",Gr," since I am starting to herd");
        jmoise.remove_group(Gr)
     }{
        !check_small_herd_grp(Gr,Leaders)
     }.

+!change_to_herding[scheme(Sch),mission(Mission),group(Gr)].
     
{ end }  

+!ask_all_cows([],[]).
+!ask_all_cows([L|Leaders],Cows)
  <- .send(L,askAll,cow(_,_,_),LC);
     //.print("xxx cows from ",L," are ",LC);
     !ask_all_cows(Leaders,RC);
     .concat(LC,RC,Cows).

     
+!check_small_herd_grp(_,[]).
+!check_small_herd_grp(MyGr,[L|Leaders])
  <- //.print("TTT send askall to ",L); 
     .send(L,askAll,play(_, herdboy, _), LBoys);
     .send(L,askOne,current_cluster(_),current_cluster(LCluster));
     .print("TTT boys of ",L," are ",LBoys," his cluster size is ", .length(LCluster));
     if (not has_enough_boys( .length(LBoys), .length(LCluster))) { 
        .send(L,askOne,group(herding_grp,OtherGr)[owner(L)],group(herding_grp,OtherGr));
        
        .findall(Scouter,play(Scouter,scouter,MyGr),LScouters);
        .send(LScouters,achieve,change_role(herdboy,OtherGr));
        !!change_role(herdboy,OtherGr);
        .print("TTT Removing group ",MyGr," since I am starting to herd in group ",OtherGr);
        jmoise.remove_group(MyGr)
        //.send(L,askOne,play(L, herder, _),play(L, herder, Gi));
        //.print("TTT entering the herding group ",Gi," of ",L);
        //!change_role(herdboy,Gi)
     }{
        !check_small_herd_grp(MyGr,Leaders)
     }.

/* -- plans for the goals of role scouter -- */

{ begin maintenance_goal("+pos(_,_,_)") }

+!follow_leader[scheme(Sch),mission(Mission),group(Gr)]
   : play(Leader, explorer, Gr)
  <- .print("ooo I should follow the leader ",Leader);
     ?pos(MyX,MyY,_);
     ?ally_pos(Leader,LX,LY);
     ?ag_perception_ratio(AGPR);
     jia.dist(MyX, MyY, LX, LY, DistanceToLeader);
     
     // If I am far from him, go to him
     if( DistanceToLeader > (AGPR * 2) -3) {
        .print("ooo approaching leader.");
        -+target(LX,LY)
     } {
        .print("ooo being in formation with leader.");
        .send(Leader,askOne,target(_,_),target(TX,TY));
        jia.scouter_pos(LX, LY, TX, TY, SX, SY);
        -+target(SX,SY)
     }.
     
+!follow_leader[scheme(Sch),mission(Mission),group(Gr)]
  <- .print("ooo I should follow the leader (",Sch,"), BUT i don't know who it is! Try later.... ").
         
{ end }  

