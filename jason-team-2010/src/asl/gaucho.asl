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

/* -- Plans -- */

+?pos(X, Y, S)
  <- .wait({+pos(X,Y,S)}).
  
+?gsize(W,H)
  <- .wait({+gsize(W,H)}).
  
+?group(team,G)
  <- .wait({+group(team,G)}, 500, _);
     ?group(team,G).
     
+?ally_pos(Name,X,Y) : .my_name(Name) <- ?pos(X,Y,_).

+corral(UpperLeftX,UpperLeftY,DownRightX,DownRightY)
  <- -+corral_center( (UpperLeftX + DownRightX)/2, (UpperLeftY + DownRightY)/2).
  
/* -- Rules -- */
  
corral_half_width(W)
  :- switch(X,Y) & jia.is_corral_switch(X,Y) &
     is_horizontal(X,Y) &
     corral(_UpperLeftX,UpperLeftY,_DownRightX,DownRightY) &   
     W = math.abs(UpperLeftY - DownRightY)/2.
   
corral_half_width(W)
  :- switch(X,Y) & jia.is_corral_switch(X,Y) &
     is_vertical(X,Y) &
     corral(UpperLeftX,_UpperLeftY,DownRightX,_DownRightY) &
     W = math.abs(UpperLeftX - DownRightX)/2.
   
@fimdesimulacao[atomic]
+end_of_simulation(_Result)
  <- -end_of_simulation(_);
     .drop_all_desires;
	 .abolish(cow(_,_,_));
     !remove_org.

/*+!restart
   : not .intend(restart) &
     .my_name(Me) &
     not commitment(Me,_, _) &
     agent_id(Me,AgId) &
     AgId mod 2 == 1 // I have an odd Id
  <- .print("[gaucho.asl] Restarting an agent with an odd id");
     ?random_pos(X,Y);
     +target(X,Y);
     .wait({+at_target},2000,_);
     !explore.*/

+!restart
   : not .intend(restart) &
     .my_name(Me) & 
   //  not commitment(Me,_, _) & 
     scheme_group(Sch,_) &
     scheme(pass_fence_sch,Sch)
  <- .print("[gaucho.asl] Trying to pass fence, not restarting agent: ", Me).
     
     
+!restart
   : not .intend(restart) &
     .my_name(Me) & 
     not commitment(Me,_, _)
  <- .print("[gaucho.asl] Restarting the agent ", Me);
     !quit_all_missions_roles;
     !explore.
     /*.print("[gaucho.asl] Restarting an agent with an even id"); 
     !quit_all_missions_roles;
     
     // try to adopt scouter in some exploration
     .findall(GE, group(exploration_grp,GE),  LGE);
     !try_adopt(scouter,LGE);
	 
	 // if I still have no role, try herdboy
     if ( not play(Me,_,_) ) {
        .findall(GH, group(herding_grp,GH),  LGH);
        !try_adopt(herdboy,LGH)
     };
     
	 // if I still have no role, try to move
     if ( not play(Me,_,_) & random_pos(X,Y) ) {
        .print("[gaucho.asl] No more groups to try a role! Going randomly somewhere! pos = ", X, ",", Y);
        -+target(X,Y)
     }.*/

+!restart
   : .my_name(Me) &
     commitment(Me,Mis, _)
  <- .print("[gaucho.asl] Restart not applicable, I am committed to ",Mis).
  
+!restart
  <- .print("[gaucho.asl] Restart not applicable").
  
+!try_adopt(_Role,[]).

+!try_adopt(Role,[G|_])
   : group(exploration_grp,G)[owner(O)] &
     ally_pos(O,OX,OY) &
     pos(MyX,MyY,_) &
     jia.path_length(MyX, MyY, OX, OY, _, fences) &
     not (scheme_group(Sch,G) & scheme(pass_fence_sch,Sch))	 // do not enter in groups passing fences
  <- .print("[gaucho.asl] Adopting role ", Role, " in group ", G);
     jmoise.adopt_role(Role,G).
     
+!try_adopt(Role,[G|_])
   : group(herding_grp,G)[owner(O)] &
     ally_pos(O,OX,OY) &
     pos(MyX,MyY,_) &
     jia.path_length(MyX, MyY, OX, OY, _, fences)
  <- .print("[gaucho.asl] Trying to adopting role ", Role, " in group ", G);
     .send(O,askAll,play(_, herdboy, _), LBoys);
     .send(O,askOne,cluster_group(_, _, _, _, _),cluster_group(_, _, _, SizeCluster, _));
     if (not too_much_boys(.length(LBoys)+1, SizeCluster)) { // do not join a group with enough boys
        .print("[gaucho.asl] Adopting role ", Role, " in group ",G); 
        !quit_all_missions_roles;
        jmoise.adopt_role(Role,G)
     }.
     
-!try_adopt(Role,[_|RG])
  <- .wait(500); 
     !try_adopt(Role,RG).

/* -- general organisational plans -- */

// remove all groups and schemes (only agent1 does that)
+!remove_org
   : .my_name(gaucho1)
  <- .print("[gaucho.asl] Removing all groups and schemes");
     if( group(team,Old) ) {
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
   : .my_name(Me) &
     play(Me,R,G).
   
+!change_role(NewRole,GT)[source(S)]
  <- .my_name(Me); 
	 .print("[gaucho.asl] Changing to role ",NewRole," in group ",GT,", as asked by ",S);
	 
     // if I play herder in another group, and my new role is herdboy (the groups are merging)...
     if( NewRole == herdboy & play(Me,herder,G) & G \== GT) {
	    // ask all herdboys to also change the group
		// and I need to wait that everybody has moved (see problem of concurrent merging)
		!wait_no_players(herdboy,G,GT)
	 };
     !quit_all_missions_roles;
     jmoise.adopt_role(NewRole,GT).

/*-!change_role(NewRole,GT)[source(S)]
  <- .print("[gaucho.asl] Fail event for change_role was generated!");
	if (NewRole == explorer | NewRole == scouter) {
		.print("[gaucho.asl] Going to try to explore again!");
		!explore
	}.*/

+!wait_no_players(R,G,GT)
   : not play(_,R,G)
  <- .print("[gaucho.asl] All the agents changed ").

+!wait_no_players(R,G,GT) 
  <- .findall(Ag,play(Ag,R,G),Ags);
	 .send(Ags, achieve, change_role(R,GT));
     .print("[gaucho.asl] Waiting agents ", Ags, " with role ", R, " to change from group ", G, " to group ", GT); 
     .wait(1000);
     !wait_no_players(R,G,GT).
  
+!quit_all_missions_roles
  <- .my_name(Me);
  
	 // if I play any other role, give it up
     while( play(Me,R,OG) ) {
        .print("[gaucho.asl] Removing my role ",R," in ",OG);
        jmoise.remove_role(R,OG)
     };
     
     // give up all missions
	 while( commitment(Me,M,Sch) ) {
        .print("[gaucho.asl] Removing my mission ",M," in ",Sch);
        jmoise.remove_mission(M,Sch)
	 }.
	 
-!quit_all_missions_roles[error_msg(M),code(C)]
  <- .println("[gaucho.asl] Error: ",C," - ",M). // no problem if it fails, it is better to continue

	 
+!quit_gatekeeper1_role
  <- .my_name(Me);
  	?play(Me,gatekeeper1,OG);
  	.print("[gaucho.asl] Removing gatekeeper1 role!");
 	jmoise.remove_role(gatekeeper1,OG).
 		 
-!quit_gatekeeper1_role[error_msg(M),code(C)]
  <- .println("[gaucho.asl] Error: ",C," - ",M). // no problem if it fails, it is better to continue
	 
	 
	 
	 
+!remove_scheme_next_cicles(Sch)
  <- .wait( { +pos(_,_,_) } );
     .wait( { +pos(_,_,_) } );
     jmoise.remove_scheme(Sch).
  	 
// finish the scheme if it has no more players
// and it was created by me
//+sch_players(Sch,0) 
//   :  .my_name(Me) & scheme(_, Sch)[owner(Me)]
//   <- jmoise.remove_scheme(Sch).


// when I have an obligation or permission to a mission, commit to it
+obligation(Sch, Mission) 
  <- .print("[gaucho.asl] Obligation to commit to mission ",Mission, " in scheme ", Sch);
     jmoise.commit_mission(Mission,Sch).
     
+permission(Sch, Mission)
  <- .print("[gaucho.asl] Permission to commit to mission ",Mission, " in scheme ", Sch);
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
  <- .print("[gaucho.asl] Removing all desires related to scheme ",Sch," and mission ",Mission);
     .drop_desire(_[scheme(Sch),mission(Mission)]).

// if some scheme is finished, drop all intentions related to it.
-scheme(_Spec,Sch)
  <- .print("[gaucho.asl] Removing all desires related to scheme ",Sch);
     .drop_desire(_[scheme(Sch)]).
//     .abolish(_[scheme(Sch)]).

// If my group is removed, remove also the schemes	 
-group(_Spec,Gid)[owner(Me)]
   : .my_name(Me)
  <- while( scheme(_,SchId)[owner(Me)] & not scheme_group(SchId, _) ) {
	    .print("[gaucho.asl] Removing scheme (SchId: ", SchId, ") without responsible group");
	    jmoise.remove_scheme(SchId)
	 }.


/* -- includes -- */

{ include("goto.asl") }         // include plans for moving around
{ include("exploration.asl") }  // include plans for exploration
{ include("herding.asl") }      // include plans for herding
{ include("pass_fence.asl") }      // include plans for pass_fence scheme
// { include("moise-common.asl") } // include common plans for MOISE+ agents

