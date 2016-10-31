/* 
   Perceptions
      Beginning:
        gsize(Weight,Height)
        steps(MaxSteps)
        corral(UpperLeft.x,UpperLeft.y,DownRight.x,DownRight.y)
        ag_perception_ratio(X). // ratio of perception of the agent
        
      Each step:
        pos(X,Y,Step)
        cow(Id,X,Y)
        ally_pos(Name,X,Y)

      End:
        end_of_simulation(Result)

*/

/* -- initial beliefs -- */

/* -- initial goals -- */

/* -- plans -- */

+?pos(X, Y, S)       <- .wait({+pos(X,Y,S)}).
//+?group_area(Id,G,A) <- .wait("+group_area(Id,G,A)").
+?gsize(W,H)         <- .wait({+gsize(W,H)}).
+?group(team,G)      <- .wait({+group(team,G)}, 500, _); ?group(team,G).
+?ally_pos(Name,X,Y) : .my_name(Name) <- ?pos(X,Y,_).

+corral(UpperLeftX,UpperLeftY,DownRightX,DownRightY)
  <- -+corral_center( (UpperLeftX + DownRightX)/2, (UpperLeftY + DownRightY)/2).
  
corral_half_width(W) :- 
   switch(X,Y) & jia.is_corral_switch(X,Y) &
   is_horizontal(X,Y) &
   corral(_UpperLeftX,UpperLeftY,_DownRightX,DownRightY) &   
   W = math.abs(UpperLeftY - DownRightY)/2.
corral_half_width(W) :- 
   switch(X,Y) & jia.is_corral_switch(X,Y) &
   is_vertical(X,Y) &
   corral(UpperLeftX,_UpperLeftY,DownRightX,_DownRightY) &
   W = math.abs(UpperLeftX - DownRightX)/2.
   
  
+end_of_simulation(_Result)
  <- -end_of_simulation(_);
     .drop_all_desires;
     .abolish(cow(_,_,_));
     !remove_org.

+!restart
   : not .intend(restart) &
     .my_name(Me) &
     not commitment(Me,_, _) & //  not play(Me,_,_) &
     agent_id(Me,AgId) &
     AgId mod 2 == 1       // I have an odd Id
  <- .print("*** restart -- odd ***");
     ?random_pos(X,Y);
     +target(X,Y);
     .wait({+at_target},2000,_);
     !create_exploration_gr.

+!restart
   : not .intend(restart) &
     .my_name(Me) & 
     not commitment(Me,_, _) // play(Me,_,_)
  <- .print("*** restart -- even ***"); 
     !quit_all_missions_roles;

     .my_name(Me);
     // try to adopt scouter in some exploration
     .findall(GE, group(exploration_grp,GE),  LGE);
     !try_adopt(scouter,LGE);
     
     // if I still have no role, try herdboy
     if ( not play(Me,_,_) ) {
        .findall(GH, group(herding_grp,GH),  LGH);
        !try_adopt(herdboy,LGH)
     };
     
     // if I still have no role, try to move
     //if ( not play(Me,_,_) & switch(X,Y) & not pos(X,Y,_) & pos(MyX,MyY,_) & jia.path_length(MyX, MyY, X, Y, _, fences)) {
     //   .print("ooo no more groups to try a role! going to a switch ",X,",",Y,", just in case it helps someone else!");
     //   -+target(X,Y)
     //}{
        if ( not play(Me,_,_) & random_pos(X,Y) ) { // try to pass fence anyway, so commented  the following: & pos(MyX,MyY,_) & jia.path_length(MyX, MyY, X, Y, _, fences)) {
           //.print("ooo no more groups to try a role! and I don't know where another switch is, random!");
           .print("ooo no more groups to try a role! random!");
           -+target(X,Y)
     //   }
     }.

+!restart : .my_name(Me) & commitment(Me,Mis, _) <- .print("restart not applicable, I am committed to ",Mis).
+!restart <- .print("restart not applicable").
  
+!try_adopt(_Role,[]).
+!try_adopt(Role,[G|_])
   : group(exploration_grp,G)[owner(O)] & ally_pos(O,OX,OY) & pos(MyX,MyY,_) & jia.path_length(MyX, MyY, OX, OY, _, fences) &
     not (scheme_group(Sch,G) & scheme(pass_fence_sch,Sch))  // do not enter in groups passing fences
  <- .print("ooo try role ",Role, " in ",G);
     jmoise.adopt_role(Role,G).
+!try_adopt(Role,[G|_])
   : group(herding_grp,G)[owner(O)] & ally_pos(O,OX,OY) & pos(MyX,MyY,_) & jia.path_length(MyX, MyY, OX, OY, _, fences)
  <- .print("ooo try role ",Role, " in ",G);
     .send(O,askAll,play(_, herdboy, _), LBoys);
     .send(O,askOne,current_cluster(_),current_cluster(LCluster));
     .print("TTT - in try role - boys of ",O," are ",LBoys," his cluster size is ", .length(LCluster));
     if (not has_enough_boys( .length(LBoys), .length(LCluster))) { // do not join a group with enough boys
        .print("TTT - in try role - taking role ",Role," in ",G); 
        jmoise.adopt_role(Role,G)
     }.
-!try_adopt(Role,[_|RG])
  <- .wait(500); 
     !try_adopt(Role,RG).
  

/* -- plans for the goals of all roles -- */


//+!share_seen_cows[scheme(Sch)] <- .print("ooo start sharing cows in scheme ",Sch); .suspend.

// simple implementation of share_cows 
+cow(Id,X,Y)[source(percept),step(C)]
   : .my_name(Me) & play(Me,_,Gr) & 
     (play(Leader,explorer,Gr) | play(Leader,herder,Gr)) &
     Leader \== Me // .intend(share_seen_cows) 
  <- //.print("ooo send cow ",cow(Id,X,Y));
     //jmoise.broadcast(Gr, tell, cow(Id,X,Y)).
     .send(Leader, tell, cow(Id,X,Y)[step(C)]).

/* // seems not to work correctly
+cow(Id,X,Y)[source(A),step(S)]
   : A \== percept
  <- for( cow(Id,OX, OY)[step(OS)] ) {
        if (not (OX == X & OY == Y)) {
           .print("qqq someone told me about the cow ",Id," seen on step ",S," but I also believe it is in another place, based on step ",OS);
           if (S > OS) {
               .print("qqq removing my bel for cow ",Id);
               .abolish( cow(Id, OX, OY) )
           }{
               .print("qqq removing what was told for cow ",Id);       
               .abolish( cow(Id, X, Y) )
           }
        }
     }. 
*/

  
-cow(Id,X,Y)[source(percept)]
   //: .my_name(Me) & play(Me,_,Gr) //& (play(Leader,explorer,Gr) | play(Leader,herder,Gr)) // .intend(share_seen_cows) 
  <- //.print("ooo broadcast untell cow ",cow(Id,X,Y));
     .broadcast( untell, cow(Id,X,Y)).
     //.send(Leader, untell, cow(Id,X,Y)).



/* -- general organisational plans -- */

// remove all groups and schemes (only agent1 does that)
+!remove_org
   : .my_name(gaucho1)
  <- if( group(team,Old) ) {
        jmoise.remove_group(Old)
     };
     
     for( scheme(_,SchId) ) {
        jmoise.remove_scheme(SchId)
     }.
+!remove_org.

  
// get the list G of participants of the group where I play R
+?my_group_players(G,R) 
  <- .my_name(Me);
     ?play(Me,R,Gid);
     .findall(P, play(P,_,Gid), G).


+!change_role(R,G)
   : .my_name(Me) & play(Me,R,G).
   
+!change_role(NewRole,GT)[source(S)]
  <- .my_name(Me); 
     .print("ooo Changing to role ",NewRole," in group ",GT,", as asked by ",S);
     
     // if I play herder in another group, and my new role is herdboy (the groups are merging)...
     if( NewRole == herdboy & play(Me,herder,G) & G \== GT) {
        // ask all herdboys to also change the group
        // and I need to wait that everybody has moved (see problem of concurrent merging)
        !wait_no_players(herdboy,G,GT)
     };
     !quit_all_missions_roles;
     jmoise.adopt_role(NewRole,GT).
     
+!wait_no_players(R,G,GT) : not play(_,R,G).
+!wait_no_players(R,G,GT) 
  <- .findall(Ag,play(Ag,R,G),Ags);
     .send(Ags, achieve, change_role(R,GT));
     .print("ooo waiting no players of ",R," in ",G," current players are ",Ags); 
     .wait(1000);
     !wait_no_players(R,G,GT).
     
// causes a loop:
// -!change_role(R,G)    
//  <- .wait(500); !change_role(R,G).
  
+!play_role(R,G)
   : .my_name(Me) & play(Me,R,G).
+!play_role(Role,Group)[source(Ag)]
  <- .print("ooo Adopting role ",Role," in group ",Group,", as asked by ",Ag);
     jmoise.adopt_role(Role, Group).
-!play_role(_,_)[error_msg(M),code(C)]
  <- .print("* Error in ",C,": ",M).

+!quit_all_missions_roles
  <- .my_name(Me);
  
     // if I play any other role, give it up
     while( play(Me,R,OG) ) {
        .print("ooo Removing my role ",R," in ",OG);
        jmoise.remove_role(R,OG) //; .wait(200)
     };
     
     // give up all missions
     while( commitment(Me,M,Sch) ) {
        .print("ooo Removing my mission ",M," in ",Sch);
        jmoise.remove_mission(M,Sch) //; .wait(200)
     }.
-!quit_all_missions_roles[error_msg(M),code(C)] <- .println("*** ",C," - ",M). // no problem if it fails, it is better to continue

     
+!remove_scheme_next_cicles(Sch)
  <- .wait( { +pos(_,_,_) } ); .wait( { +pos(_,_,_) } );
     jmoise.remove_scheme(Sch).
     
// finish the scheme if it has no more players
// and it was created by me
//+sch_players(Sch,0) 
//   :  .my_name(Me) & scheme(_, Sch)[owner(Me)]
//   <- jmoise.remove_scheme(Sch).


// when I have an obligation or permission to a mission, commit to it
+obligation(Sch, Mission) 
  <- .print("ooo Obligation to commit to mission ",Mission, " in scheme ", Sch);
     jmoise.commit_mission(Mission,Sch).
+permission(Sch, Mission)
  <- .print("ooo Permission to commit to mission ",Mission, " in scheme ", Sch);
     jmoise.commit_mission(Mission,Sch).

// when I am not obligated to a mission anymore, uncommit
/*
-obligation(Sch, Mission)
   : .my_name(Me) & commitment(Me,Mission,Sch)
  <- .print("ooo I don't have obligation for the mission ",Mission," in ",Sch," anymore, remove the commitment");
     jmoise.remove_mission(Mission,Sch).
-permission(Sch, Mission)
   : .my_name(Me) & commitment(Me,Mission,Sch)
  <- .print("ooo I don't have permission for the mission ",Mission," in ",Sch," anymore, remove the commitment");
     jmoise.remove_mission(Mission,Sch).
*/

// if I lost my mission in scheme open-corral/pass_fence, find another thing to do
/*-commitment(Me, porter1, Sch)
   : scheme(pass_fence,Sch) | schme(open_corral,Sch) 
  <- .print("yyyy add restart because my ",Mission," mission finished");
     .drop_desire(_[scheme(Sch),mission(Mission)]);
     !restart.
*/

// when I am not committed to a mission anymore, remove all goals based on that mission
-commitment(Me,Mission,Sch)
   : .my_name(Me)
  <- .print("ooo Removing all desires related to scheme ",Sch," and mission ",Mission);
     .drop_desire(_[scheme(Sch),mission(Mission)]).

// if some scheme is finished, drop all intentions related to it.
-scheme(_Spec,Sch)
  <- .print("ooo Removing all desires related to scheme ",Sch);
     .drop_desire(_[scheme(Sch)]);
     .abolish(_[scheme(Sch)]).

// If my group is removed, remove also the schemes   
-group(_Spec,Gid)[owner(Me)]
   : .my_name(Me)
  <- while( scheme(_,SchId)[owner(Me)] & not scheme_group(SchId, _) ) {
        .print("ooo yyyyy removing scheme without responsible group ",SchId);
        jmoise.remove_scheme(SchId)
     }.


/* -- includes -- */

{ include("goto.asl") }         // include plans for moving around
{ include("exploration.asl") }  // include plans for exploration
{ include("herding.asl") }      // include plans for herding
{ include("pass_fence.asl") }      // include plans for pass_fence scheme
// { include("moise-common.asl") } // include common plans for MOISE+ agents

