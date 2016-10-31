// Agent usp in project jason-team-2010

+?pos(X, Y, S)
  <- .wait({+pos(X,Y,S)}).
  
+?gsize(W,H)
  <- .wait({+gsize(W,H)}).
  
+?group(team,G)
  <- .wait({+group(team,G)}, 500, _);
     ?group(team,G).
     
+?ally_pos(Name,X,Y) : .my_name(Name) <- ?pos(X,Y,_).

// get the list L of participants of the group where I play Role R
+?my_group_players(L,R) 
  <- .my_name(Me);
     ?play(Me,R,Pid);
     .findall(P, play(P,_,Pid), L).




+corral(UpperLeftX,UpperLeftY,DownRightX,DownRightY)
  <- -+corral_center( (UpperLeftX + DownRightX)/2, (UpperLeftY + DownRightY)/2).
  
  
@fimdesimulacao[atomic]
+end_of_simulation(_Result)
  <- -end_of_simulation(_);
     .drop_all_desires;
	 .abolish(cow(_,_,_));
     !remove_org.
     
     
     
/*
*  Restarting Achievments  
*/

// The agent is whaiting for another pass_fence scheme to be accomplished. 
+!restart
 :	not .intend(restart) &
 	.my_name(Me) &  
    scheme_group(Sch,_) &
    scheme(pass_fence_sch,Sch)
 <- .print("[usp.asl] I'm in another pass_fence scheme, shouldn't restart").

// Here, if I'm not commited to something, then.. I should restart.
+!restart
 : 	not .intend(restart) &
 	.my_name(Me) &
 	not commitment(Me,_,_)
 <- .print("[usp.asl] Restarting agent!");
 	!quit_all_missions_roles;
 	!!explore.

// finally, if i'm commited to something, then, don't restart.
+!restart
<- .print("not restarting").

/*
*  Adopting Roles Achievments
*/


// there's no Group, so no adopting!
+!try_adopt(_Role,[]).

// enter groups that aren't trying to pass fences.
+!try_adopt(Role,[G|_])
   : group(exploration_grp,G)[owner(O)] &
     ally_pos(O,OX,OY) &
     pos(MyX,MyY,_) &
     jia.path_length(MyX, MyY, OX, OY, _, fences) &
     not (scheme_group(Sch,G) & scheme(pass_fence_sch,Sch))	 // do not enter in groups passing fences
  <- .print("[usp.asl] Adopting role ", Role, " in group ", G);
     jmoise.adopt_role(Role,G).
     
// go to next group
+!try_adopt(Role,[_|OtG])
 <-	.wait(500); 
 	!!try_adopt(Role,OtG).

/*
*	Removing All Groups and Schemes
*/

// I'm usp1, so I should do this
+!remove_org
   : .my_name(usp1)
  <- .print("[usp.asl] Removing all groups and schemes");
     if( group(team,Old) ) {
        jmoise.remove_group(Old)
     };
     
     for( scheme(_,SchId) ) {
        jmoise.remove_scheme(SchId)
     }.
     
// I'm not usp1, so do nothing
+!remove_org.


/*
*	Changing Roles!
*/

// If I already play this role on some group, do nothing!

+!change_role(R,G)
   : .my_name(Me) &
     play(Me,R,G).


+!change_role(NewRole,GT)[source(S)]
  <- .my_name(Me); 
	 .print("[usp.asl] Changing to role ",NewRole," in group ",GT,", as asked by ",S);
	 
     // if I play herder in another group, and my new role is herdboy (the groups are merging)...
     if( NewRole == herdboy & play(Me,herder,G) & G \== GT) {
	    // ask all herdboys to also change the group
		// and I need to wait that everybody has moved (see problem of concurrent merging)
		!wait_no_players(herdboy,G,GT)
	 };
     !quit_all_missions_roles;
     .print("[usp.asl] Trying to adopt role ", NewRole, " in group ", GT);
     jmoise.adopt_role(NewRole,GT).


/*
*	Waiting until all the players in my group (G) have changed to GT
*/
  
 
+!wait_no_players(R,G,GT)
   : not play(_,R,G)
  <- .print("[usp.asl] All the agents changed ").

+!wait_no_players(R,G,GT) 
  <- .findall(Ag,play(Ag,R,G),Ags);
	 .send(Ags, achieve, change_role(R,GT));
     .print("[usp.asl] Waiting agents ", Ags, " with role ", R, " to change from group ", G, " to group ", GT); 
     .wait(1000);
     !wait_no_players(R,G,GT).
  
  
/*
*	Quit all roles.
*/

+!quit_all_missions_roles
  <- .my_name(Me);
  
  	 // if I play any other role, give it up
	while( play(Me,R,OG) ) {
        	.print("[usp.asl] Removing my role ",R," in ",OG);
		jmoise.remove_role(R,OG)
	};
  
  
     // give up all missions
	while( commitment(Me,M,Sch) ) {
        	.print("[usp.asl] Removing my mission ",M," in ",Sch);
        	jmoise.remove_mission(M,Sch)
	};
	.print("[usp.asl] All Roles and Missions removed!").
	 
//-!quit_all_missions_roles[error_msg(M),code(C)]
  //<- .println("[usp.asl] Error: ",C," - ",M). // no problem if it fails, it is better to continue
  

+!quit_gatekeeper1_role 
  <- .my_name(Me);
  	?play(Me,gatekeeper1,OG);
  	.print("[usp.asl] Removing gatekeeper1 role!");
 	jmoise.remove_role(gatekeeper1,OG);
 	!adopt_role_for_group(OG).
 	
+!adopt_role_for_group(OG)
: group(exploration_grp,OG)[owner(O)]
	<-	.print("[usp.asl] Adopting scouter in ",OG);
		jmoise.adopt_role(scouter,OG).

+!adopt_role_for_group(OG)
: group(herding_grp,OG)[owner(O)]
	<-	.print("[usp.asl] Adopting herdboy in ",OG);
		jmoise.adopt_role(herdboy,OG). 	
 	
 		 
-!quit_gatekeeper1_role[error_msg(M),code(C)]
  <- .println("[usp.asl] Error: ",C," - ",M). // no problem if it fails, it is better to continue
	 
/*
* 	Wait Two cicles and then remove schemes!
*/  

+!remove_scheme_next_cicles(Sch)
  <- .wait( { +pos(_,_,_) } );
     .wait( { +pos(_,_,_) } );
     jmoise.remove_scheme(Sch).
     
     
/*
*	Link to moise.
*/
     // when I have an obligation or permission to a mission, commit to it
+obligation(Sch, Mission) 
  <- .print("[usp.asl] Obligation to commit to mission ",Mission, " in scheme ", Sch);
     jmoise.commit_mission(Mission,Sch).
     
+permission(Sch, Mission)
  <- .print("[usp.asl] Permission to commit to mission ",Mission, " in scheme ", Sch);
     jmoise.commit_mission(Mission,Sch).
     
     
     
/*
*	Security belief deletion perceiver.
*/
/*     
// when I am not committed to a mission anymore, remove all goals based on that mission
-commitment(Me,Mission,Sch)
   : .my_name(Me)
  <- .print("[usp.asl] SBDP Removing all desires related to scheme ",Sch," and mission ",Mission);
     .drop_desire(_[scheme(Sch),mission(Mission)]).

// if some scheme is finished, drop all intentions related to it.
-scheme(_Spec,Sch)
  <- .print("[usp.asl] SBDP Removing all desires related to scheme ",Sch);
     .drop_desire(_[scheme(Sch)]).
//     .abolish(_[scheme(Sch)]).

// If my group is removed, remove also the schemes	 
-group(_Spec,Gid)[owner(Me)]
   : .my_name(Me)
  <- while( scheme(_,SchId)[owner(Me)] & not scheme_group(SchId, _) ) {
	    .print("[usp.asl] SBDP Removing scheme (SchId: ", SchId, ") without responsible group");
	    jmoise.remove_scheme(SchId)
	 }.
*/
	 
/*
*	Other files
*/
	 
{ include("gotoUSP.asl") }         // include plans for moving around
{ include("explorationUSP.asl") }  // include plans for exploration
{ include("herdingUSP.asl") }      // include plans for herding
{ include("pass_fenceUSP.asl") }      // include plans for pass_fence scheme
