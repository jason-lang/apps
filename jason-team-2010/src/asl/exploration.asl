/* -- plans for exploration phase -- */


/*
   -- plans for new match 
   -- create the initial exploration groups and areas 
*/


+gsize(_,_)                             // new match has started 
  <- !define_areas;
     !!execute_change_to_herding;
     !start_exploration.

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

+!start_exploration
   : .my_name(Me) &
	agent_id(Me,MyId) &
     (MyId mod 4) == 1 &  //Agentes com ids ímpares
	not .intend(start_exploration)
  <- .print("[exploration.asl] Start exploration! MyId=",MyId, " (odd id)");
	// create the team, if necessary
	if( Me == gaucho1 & not group(team,_) ) {
     	jmoise.create_group(team) 
	};
	!create_exploration_gr.

+!start_exploration
   : .my_name(Me) &
	agent_id(Me,MyId) &
     (MyId mod 4) \== 1 &  //Agentes com ids pares
	not .intend(start_exploration)
  <- .print("[exploration.asl] Start exploration! MyId=",MyId, " (even id)");
	.wait({+pos(_,_,_)});
	!explore.

+!start_exploration.
/* TODO terminar
+!explore
: .my_name(Me) &
	not play(Me,_,_) &
	not .intend(explore) &
	not group(exploration_grp,_)[owner(Me)]
	<- 	.print("[exploration.asl] Explore!");
		.findall(Leader_explor,group(exploration_grp,Gr)[owner(Leader_explor)],Leaders);
	*/	
		
		
		
+!explore
   : .my_name(Me) &
	not play(Me,_,_) &
	not .intend(explore) &
	agent_id(Me,MyId) &
     not (MyId mod 4) == 1   
  <- .print("[exploration.asl] Explore!");
     -+minDist(1000,0);
     if( not group(exploration_grp,_)[owner(Me)] ) {
	    .findall(grupo(Ag,Gr), group(exploration_grp,Gr)[owner(Ag)],Explorers);
	    ?pos(MyX,MyY,_);
        for ( .member(grupo(E,Grupo),Explorers)) {
            .send(E, askAll, play(_,scouter,Grupo), Reply, 100);
            .send(E, askOne, pos(_, _, _), Reply2, 100);
            if (Reply \== timeout & Reply \== false & Reply2 \== timeout & Reply2 \== false) {
				Reply2 = pos(AgX, AgY, _);
				if (jia.path_length(MyX, MyY, AgX, AgY, D, fences)) {
		           .length(Reply, NR);
		           ?minDist(N,_);
			       .print("[exploration.asl] Explore E=", E, ", NR=", NR, ", D=", D, ", N=", N);
			       if (NR < 3 & D < N) {
			           -+minDist(D,Grupo)
		           }
                }
            }
		};
		?minDist(NEscolhido,GrEscolhido);
	     .print("[exploration.asl] Explore NEscolhido=", NEscolhido, ", GrEscolhido=", GrEscolhido);
	     if (NEscolhido < 1000) {
	        !change_role(scouter,GrEscolhido)
	     } //else {
	     //   !create_exploration_gr
	     //}
	 };
	 -minDist(_,_).

		
+!explore
   : agent_id(Me,MyId) &
     (MyId mod 4) == 1   //Agentes com ids ímpares
     <- !!start_exploration.

+!explore.

+!create_exploration_gr
   : .my_name(Me) &
	 not .intend(create_exploration_gr)
  <- // create the exploration group
     if( not group(exploration_grp,_)[owner(Me)] ) {
	    ?group(team,TeamGroup); // get the team Id
        jmoise.create_group(exploration_grp,TeamGroup,G);
		.print("[exploration.asl] Exploration group ",G," created")
     } else {
	    ?group(exploration_grp,G)[owner(Me)]
     };
     
     // adopt role explorer in the group
     !change_role(explorer,G);
     
     // create the scheme
     if ( not (scheme(explore_sch,S) & scheme_group(S,G)) ) {
        .print("[exploration.asl] Creating exploration scheme for group ",G);
        -target(_,_); // remove target so that a new one is selected by near unvisited
        jmoise.create_scheme(explore_sch, [G])
     }.
     
+!create_exploration_gr.

-!create_exploration_gr
  <- !explore.
          
// If I stop playing explorer, destroy the explore scheme/group I've created
-play(Me,explorer,G)
   : .my_name(Me)
  <- .wait({+pos(_,_,_)});

	for( scheme(explore_sch,S)[owner(Me)] ) {
	    .print("[exploration.asl] Removing scheme ",S);
	    jmoise.remove_scheme(S)
	 };
	 // -- breaks pass-fence scheme
	 for( group(exploration_grp,G)[owner(Me)] & not scheme_group(_,G)) {
	    .print("[exploration.asl] Removing group ",G," since I am not in the group anymore");
	    jmoise.remove_group(G)
	 }.

	 
	 
/* -- plans for the goals of role explorer -- */

/*{ begin maintenance_goal("+pos(_,_,_)") }

+!find_scouter[scheme(Sch),group(G)]
   : play(Ag,scouter,G)
  <- // if I can not reach my scouter anymore
     if (ally_pos(Ag,X,Y) & pos(MyX, MyY, _) & not jia.path_length(MyX, MyY, X, Y, _, fences) ) {
        .print("[exploration.asl] Asking agent ",Ag," to quite its scouter role because I cannot reach it anymore");
     	.send(Ag,achieve,quit_all_missions_roles);
     	.wait(1000);
     	.send(Ag,achieve,explore)
     }.

+!find_scouter[scheme(Sch),group(G)]
  <- .print("[exploration.asl] Telling all the agents to go explore! (They will only explore if they don't play anything more!)");
	.broadcast(achieve, explore);
	!!explore;
     ?pos(MyX,MyY,_); // wait my pos
     ?team_size(TS);
     
     // wait others pos
     while( .count(ally_pos(_,_,_), N) & N < (TS-1) ) {
        .print("[exploration.asl] Waiting others' location, I received ",N," locations until now");
        .wait({+ally_pos(_,_,_)}, 500, _)
     };
     
     // find distance to even agents
     .findall(ag_d(D,AgName),
              ally_pos(AgName,X,Y) & agent_id(AgName,Id) & Id mod 2 == 0 & jia.path_length(MyX, MyY, X, Y, D, fences),
              LOdd);
     .sort(LOdd, LSOdd);
     .print("[exploration.asl] Scouters candidates are ",LSOdd);
	 !find_scouter(LSOdd,G);
	 jmoise.set_goal_state(Sch, find_scouter, satisfied).

{ end }

+!find_scouter([],G)
  <- .print("[exploration.asl] No scouter for me!").
  
+!find_scouter([ag_d(_,AgName)|_],GId)
  <- .print("[exploration.asl] Ask ",AgName," to play scouter");
     .send(AgName, achieve, change_role(scouter,GId));
     .wait({+play(AgName,scouter,GId)},3000).  
     
-!find_scouter([_|LSOdd],GId) // in case the wait fails, try next agent
  <- .print("[exploration.asl] Find_scouter failure, try another agent from ",LSOdd);
     !find_scouter(LSOdd,GId).  */

	 
{ begin maintenance_goal("+pos(_,_,_)") } // old is +at_target

+!goto_near_unvisited[scheme(Sch),mission(Mission)]
   : not target(_,_)
     | (target(X,Y) & pos(X,Y,_)) // I am there
     | (target(X,Y) & (jia.obstacle(X,Y) | jia.fence(X,Y) | jia.corral(X,Y))) // I discovered that the target is a fence or obstacle
  <- .print("[exploration.asl] I should find the nearest unvisited location and go there!");
     .my_name(Me); 
	 ?agent_id(Me,MyId);
     ?group_area((MyId-1) div 4, Area);  // get the area of my group
     ?pos(MeX, MeY, _);              // get my location
     jia.near_least_visited(MeX, MeY, Area, TargetX, TargetY);
     .print("[exploration.asl] The nearest unvisited location is ",TargetX,",",TargetY);
     !!update_target(TargetX, TargetY).

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

/*{ begin maintenance_goal("+pos(_,_,_)") }

+!change_to_herding[scheme(Sch),mission(Mission),group(Gr)]
   : .my_name(Me) &
	 agent_id(Me,1)
  <- .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)});
     .print("[exploration.asl] change_to_herding Creating groups to herd the clusters");
     .findall(L, group_leader(_,L),Herders);
	.length(Herders, TH);

	.findall(Ag, group(exploration_grp,_)[owner(Ag)],Explorers);
     
     jia.getclusters(N, _, _);
	
	.print("[exploration.asl] change_to_herding N=",N,", TH=",TH, ", Explorers=",Explorers);

	if (N > TH) {
		-+iterador(N-TH);
		for ( .member(E,Explorers) ) {
			?iterador(I);
			-+iterador(I-1);
			if (I > 0) {
				.send(E, achieve, create_herding_gr)
			}
			
		};
		-iterador(_)
	}.

     -+nClusters(N);
     for ( .member(H,Herders)) {
	    .send(H, askOne, cluster_group(_,_,_,_,_), Reply, 100);
	    if (Reply \== timeout & Reply \== false) {
		    .print("[exploration.asl] Reply=", Reply);
		    Reply = cluster_group(_,_,_,SizeCl,LengthAg);
		    if (too_much_boys(LengthAg+NGr, SizeCl)) {
	            ?nClusters(Number);
	            -+nClusters(Number-1);
	        }
		}
	}
	?nClusters(NTotal);
	-nClusters(_);
	if (NTotal > 0) {
	    .findall(Scouter,play(Scouter,scouter,Gr),LScouters);
        !!create_herding_gr(LScouters);
        .print("[exploration.asl] Removing group ",Gr," since I am starting to herd and creating herding group");
        jmoise.remove_group(Gr)
	}.

+!change_to_herding[scheme(Sch),mission(Mission),group(Gr)].
	 
{ end }*/

+!execute_change_to_herding
   : .my_name(Me) &
	 agent_id(Me,1)
  <- .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)});
     .print("[exploration.asl] change_to_herding Creating groups to herd the clusters");
     .findall(L, group_leader(_,L),Herders);
	.length(Herders, TH);

	.findall(Ag, group(exploration_grp,_)[owner(Ag)],Explorers);
     
     jia.getclusters(N, _, _);
	
	.print("[exploration.asl] change_to_herding N=",N,", TH=",TH, ", Explorers=",Explorers);

	if (N > TH) {
		-+iterador(N-TH);
		for ( .member(E,Explorers) ) {
			?iterador(I);
			-+iterador(I-1);
			if (I > 0) {
				.send(E, achieve, create_herding_gr)
			}
			
		};
		-iterador(_)
	};
	!!execute_change_to_herding.
	
+!execute_change_to_herding.

/* -- plans for the goals of role scouter -- */

{ begin maintenance_goal("+pos(_,_,_)") }

+!follow_leader[scheme(Sch),mission(Mission),group(Gr)]
   : play(Leader, explorer, Gr)
  <- .print("[exploration.asl] I should follow the leader ",Leader);
     ?pos(MyX,MyY,_);
     ?ally_pos(Leader,LX,LY);
     ?ag_perception_ratio(AGPR);
     jia.dist(MyX, MyY, LX, LY, DistanceToLeader);
     
     // If I am far from him, go to him
     if( DistanceToLeader > (AGPR * 2) -3) {
        .print("[exploration.asl] Approaching leader.");
     	!!update_target(LX,LY)
     } else {
        .print("[exploration.asl] Being in formation with leader.");
        .send(Leader,askOne,target(_,_),Reply);
        if (Reply \== false) {
        	   Reply = target(TX,TY);
		   jia.scouter_pos(LX, LY, TX, TY, SX, SY);
		   !!update_target(SX,SY)
        } else {
        	   !!update_target(LX,LY)
        }
     }.
     
+!follow_leader[scheme(Sch),mission(Mission),group(Gr)]
  <- .print("[exploration.asl] I should follow the leader (",Sch,"), BUT i don't know who it is! Try later.... ").
	 	 
{ end }	 

