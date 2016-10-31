/* 
   Perceptions
      Begin:
        gsize(Weight,Height)
        steps(MaxSteps)
        corral(UpperLeft.x,UpperLeft.y,DownRight.x,DownRight.y)
        
      Each step:
        pos(X,Y,Step)
        cow(Id,X,Y)
        apply_pos(Name,X,Y)

      End:
        end_of_simulation(Result)

*/

/* -- initial beliefs -- */

agent_id(gaucho1,1).
agent_id(gaucho2,2).
agent_id(gaucho3,3).
agent_id(gaucho4,4).
agent_id(gaucho5,5).
agent_id(gaucho6,6).

ag_perception_ratio(8). // ratio of perception of the agent
cow_perception_ratio(4).

/* -- initial goals -- */

/* -- plans -- */

+?pos(X, Y, S)       <- .wait({+pos(X,Y,S)}).
//+?group_area(Id,G,A) <- .wait("+group_area(Id,G,A)").
+?gsize(W,H)         <- .wait({+gsize(W,H)}).
+?group(team,G)      <- .wait({+group(team,G)}, 500, _); ?group(team,G).
+?ally_pos(Name,X,Y) : .my_name(Name) <- ?pos(X,Y,_).

+corral(UpperLeftX,UpperLeftY,DownRightX,DownRightY)
  <- -+corral_center( (UpperLeftX + DownRightX)/2, (UpperLeftY + DownRightY)/2).

  
+end_of_simulation(_Result)
  <- -end_of_simulation(_);
     .drop_all_desires;
     .abolish(cow(_,_,_));
     !remove_org.

+!restart
   : .my_name(Me) &
     agent_id(Me,AgId) &
     AgId mod 2 == 1       // I have an odd Id
  <- .print("*** restart -- odd ***");
     ?random_pos(X,Y);
     +target(X,Y);
     .wait({+at_target},1000,_);
     !create_exploration_gr.
+!restart
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
     }.
  
+!try_adopt(_Role,[]).
+!try_adopt(Role,[G|_])
  <- .print("ooo try role ",Role, " in ",G);
     jmoise.adopt_role(Role,G).
-!try_adopt(Role,[_|RG])
  <- .wait(500); !try_adopt(Role,RG).
  

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
        .findall(Boy,play(Boy,herdboy,G),HerdBoys);
        .send(HerdBoys, achieve, change_role(herdboy,GT))
     };
     !quit_all_missions_roles;
     jmoise.adopt_role(NewRole,GT).
     
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
        jmoise.remove_role(R,OG)
     };
     
     // give up all missions
     while( commitment(Me,M,Sch) ) {
        .print("ooo Removing my mission ",M," in ",Sch);
        jmoise.remove_mission(M,Sch)
     }.
-!quit_all_missions_roles[error_msg(M),code(C)] <- .println("*** ",C," - ",M). // no problem if it fails, it is better to continue

     
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

// when I am not committed to a mission anymore, remove all goals based on that mission
-commitment(Me,Mission,Sch)
   : .my_name(Me)
  <- .print("ooo Removing all desires related to scheme ",Sch," and mission ",Mission);
     .drop_desire(_[scheme(Sch),mission(Mission)]).

// if some scheme is finished, drop all intentions related to it.
-scheme(_Spec,Sch)
  <- .print("ooo Removing all desires related to scheme ",Sch);
     .drop_desire(_[scheme(Sch)]).


/* -- includes -- */

{ include("goto.asl") }         // include plans for moving around
{ include("exploration.asl") }  // include plans for exploration
{ include("herding.asl") }      // include plans for herding
// { include("moise-common.asl") } // include common plans for MOISE+ agents

