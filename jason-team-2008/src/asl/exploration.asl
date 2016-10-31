/* -- plans for exploration phase -- */


/*
   -- plans for new match 
   -- create the initial exploration groups and areas 
*/


+gsize(_,_)                             // new match has started 
  <- !define_areas;
     !create_exploration_gr.

+!define_areas
  <- ?gsize(W,H);
     X = math.round(((W*H)/3)/H);
     +group_area(0, area(0,   0,       X,   H-1));
     +group_area(1, area(X+1, 0,       W-1, H/2));
     +group_area(2, area(X+1, (H/2)+1, W-1, H-1)).
     
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
     !change_role(explorer,G).
+!create_exploration_gr.
     
// If if start playing explorer in a group that has no scheme, create the scheme
+play(Me,explorer,G)
   : .my_name(Me) &
     not scheme_group(_,G)
  <- .print("Creating explore scheme");
     jmoise.create_scheme(explore_sch, [G]).
     
// If I stop playing explorer, destroy the explore scheme/group I've created
-play(Me,explorer,_)
   : .my_name(Me)
  <- for( scheme(explore_sch,S)[owner(Me)] ) {
        .print("ooo Removing scheme ",S);
        jmoise.remove_scheme(S);
        .wait(1000)
     };
     for( group(exploration_grp,G)[owner(Me)] ) {
        .print("ooo Removing group ",G," since I am not in the group anymore");
        jmoise.remove_group(G);
        .wait(1000)
     }.

     
/*+group(exploration_grp,_)                // compute the area of the groups
   : .my_name(gaucho1) &
     group(team,TeamId) &
     .findall(GId, group(exploration_grp,GId)[super_gr(TeamId)], LG) &
     LG = [G1,G2,G3]                     // there are three groups

+group_area(ID,G,A)[source(self)]
  <- .broadcast(tell, group_area(ID,G,A)).  
*/
     
/* -- plans for the goals of role explorer -- */

+!find_scouter[scheme(Sch),group(G)]
  <- .print("ooo Recruiting scouters for my explorer group ",G);
  
     // test if I received the area of my group
     //?group_area(AreaId,G,A);
     //.print("ooo Scouters candidates =", LSOdd," in area ",group_area(AreaId,G,A));
     
     !find_scouter([], G);
     jmoise.set_goal_state(Sch, find_scouter, satisfied).
-!find_scouter[scheme(Sch),group(G)]
  <- .wait(1000); !find_scouter[scheme(Sch),group(G)].
  
+!find_scouter(_,G) // if someone plays scouter in my group, it is ok.
   : play(_,scouter,G).
+!find_scouter([],G)
  <- ?pos(MyX,MyY,_); // wait my pos
     
     // wait others pos
     while( .count(ally_pos(_,_,_), N) & N < 5 ) {
        .print("ooo waiting others pos ");
        .wait({+ally_pos(_,_,_)}, 500, _)
     };
     
     // find distance to even agents
     .findall(ag_d(D,AgName),
              ally_pos(AgName,X,Y) & agent_id(AgName,Id) & Id mod 2 == 0 & jia.path_length(MyX, MyY, X, Y, D),
              LOdd);
     .sort(LOdd, LSOdd);
     !find_scouter(LSOdd,G).
+!find_scouter([ag_d(_,AgName)|_],GId)
  <- .print("ooo Ask ",AgName," to play scouter");
     .send(AgName, achieve, play_role(scouter,GId));
     .wait({+play(AgName,scouter,GId)},2000).  
-!find_scouter([_|LSOdd],GId) // in case the wait fails, try next agent
  <- .print("ooo find_scouter failure, try another agent.");
     !find_scouter(LSOdd,GId).  
     

     
{ begin maintenance_goal("+at_target") }

+!goto_near_unvisited[scheme(Sch),mission(Mission)]
  <- .print("ooo I should find the nearest unvisited location and go there!");
     .my_name(Me); 
     ?agent_id(Me,MyId);
     ?group_area(MyId div 2, Area);  // get the area of my group
     
     ?pos(MeX, MeY, _);             // get my location
     jia.near_least_visited(MeX, MeY, Area, TargetX, TargetY);
     -+target(TargetX, TargetY).
     
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


{ begin maintenance_goal("+pos(_,_,_)") }

+!change_to_herding[scheme(Sch),mission(Mission)]
   : cow(_,_,_)
  <- .print("ooo I see some cows, create the herding group");
     // check whether the seen cows are being herded by other group
     .findall(L, group_leader(_,L),Leaders);
     !ask_all_cows(Leaders,LCows);
     .findall(cow(ID,X,Y), cow(ID,X,Y), MyCows);
     .intersection(MyCows, LCows, Common);
     //.print("xxx all cows in herding groups are ",LCows," mine are ",MyCows," intersection is ",Common);
     if ( Common == [] ) {
        !!create_herding_gr
     }{
        !check_small_herd_grp(Leaders)
     }.

+!change_to_herding[scheme(Sch),mission(Mission)].
     
{ end }  

+!ask_all_cows([],[]).
+!ask_all_cows([L|Leaders],Cows)
  <- .send(L,askAll,cow(_,_,_),LC);
     //.print("xxx cows from ",L," are ",LC);
     !ask_all_cows(Leaders,RC);
     .concat(LC,RC,Cows).

     
+!check_small_herd_grp([]).
+!check_small_herd_grp([L|Leaders])
  <- .send(L,askAll,play(_, herdboy, _), LBoys);
     .send(L,askOne,current_cluster(_),current_cluster(LCluster));
     //.print("xxx boys of ",L," are ",LBoys," his cluster size is ", .length(LCluster));
     if (.length(LBoys) < 2 & .length(LCluster) > (.length(LBoys)+1)*5) {
        !!create_herding_gr
     }{
        !check_small_herd_grp(Leaders)
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
        .print("ooo Approaching leader.");
        -+target(LX,LY)
     } {
        .print("ooo being in formation with leader.");
        .send(Leader,askOne,target(_,_),target(TX,TY));
        jia.scouter_pos(LX, LY, TX, TY, SX, SY);
        -+target(SX,SY)
     }.
     
{ end }  

