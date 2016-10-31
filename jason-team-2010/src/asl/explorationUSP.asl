// Agent explorationUSP in project jason-team-2010



+?concatList(L1,L2,L) 
	:L1 \== timeout
<- .concat(L1,L2,L).

+?concatList(L1,L2,L) 
<- L = L2.

+?concatList(L1,L2,L3,L)
<- ?concatList(L1,[],LT1);
   ?concatList(L2,LT1,LT2);
   ?concatList(L3,LT2,L).


/*
*	At the beggining, we receive a +gsize(H,W)!
*/

+gsize(_,_)                             // new match has started 
 <-
 .print("[explorationUSP.asl] Match Started!"); 
  	!define_areas;
    !start_exploration.

/*
*	Each agent knows the areas. 	
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


/*
*	It is executed from the beginning.. 
*/
+!start_exploration[group(Gr)]
   : .my_name(Me) &
	agent_id(Me,MyId) &
     (MyId mod 4) == 1 & 
	not .intend(start_exploration)
<-	    jmoise.remove_group(Gr);
		!!start_exploration.
		
+!start_exploration
   : .my_name(Me) &
	agent_id(Me,MyId) &
     (MyId mod 4) == 1 & 
	not .intend(start_exploration)
  <- .print("[explorationUSP.asl] Start exploration! MyId=",MyId, " (mod4 = 1 id)");
	// create the team, if necessary
	if( Me == usp1 & not group(team,_) ) {
     	jmoise.create_group(team) 
	};
	!create_exploration_gr.

+!start_exploration
   : .my_name(Me) &
	agent_id(Me,MyId) &
     (MyId mod 4) \== 1 &  
	not .intend(start_exploration)
  <- .print("[explorationUSP.asl] Start exploration! MyId=",MyId, " (mod4 != 1 id)");
	.wait({+pos(_,_,_)});
	!explore.

+!start_exploration.

/*
*	Explore.
*/



+!explore
   : .my_name(Me) &
	not play(Me,_,_) &
	not .intend(explore) &
	agent_id(Me,MyId) &
     not (MyId mod 4) == 1   
  <- .print("[explorationUSP.asl] Explore!");
     -+minDist(1000,0);
     if( not group(exploration_grp,_)[owner(Me)] ) {
	    .findall(grupo(Ag,Gr), group(exploration_grp,Gr)[owner(Ag)],Explorers);
	    ?pos(MyX,MyY,_);
        for ( .member(grupo(E,Grupo),Explorers)) {
           // .send(E, askAll, play(_,scouter,Grupo), ReplyS, 100);
           // .send(E, askAll, play(_,gatekeeper1,Grupo), ReplyFK1, 100);
           // .send(E, askAll, play(_,gatekeeper2,Grupo), ReplyFK2, 100);
            .send(E, askOne, pos(_, _, _), Reply2, 100);
           // .print("[explorationUSP.asl] Reply: S=", ReplyS, ", FK1=", ReplyFK1, ", FK2=", ReplyFK2);
            .send(E, askAll, play(_,_,Grupo), Reply, 100);
          //  ?concatList(ReplyS,ReplyFK1,ReplyFK2,Reply);
            if (Reply \== timeout & Reply \== false & Reply2 \== timeout & Reply2 \== false) {
            //	.print("[explorationUSP.asl] Reply: S=", ReplyS, ", FK1=", ReplyFK1, ", FK2=", ReplyFK2,", R=",Reply);

				Reply2 = pos(AgX, AgY, _);
				if (jia.path_length(MyX, MyY, AgX, AgY, D)) {  // , fences
		           .length(Reply, NR);
		           ?minDist(N,_);
			       .print("[explorationUSP.asl] Explore E=", E, ", NR=", NR, ", D=", D, ", N=", N);
			       if (NR < 4 & D < N) {
			           -+minDist(D,Grupo)
		           }
                }
            }
		};
		?minDist(NEscolhido,GrEscolhido);
	     .print("[explorationUSP.asl] Explore NEscolhido=", NEscolhido, ", GrEscolhido=", GrEscolhido);
	     
	     
	    if ( NEscolhido < 1000 ) {
       		!change_role(scouter,GrEscolhido)
   		} else { 
   			.print("There's no group available, so, creating my own exploration Group");
   			if(.length(Explorers) \== 0){
   				!create_exploration_gr // não tem erro, o problema é o parser do eclipse.
   			} else {
   				!explore
   			}
  		}
	 };
	 -minDist(_,_).

+!explore
   : .my_name(Me) & 
   agent_id(Me,MyId) &
     (MyId mod 4) == 1   //Agentes com ids ímpares
     <- !!start_exploration.

+!explore.

-!explore[error_msg(M),code(C)]
  <- .println("[explorationUSP.asl] Error: ",C," - ",M);
  	.wait(100);
  	!explore.


/*
*	Actions to create Exploration Groups.
*/

+!create_exploration_gr
   : .my_name(Me) &
   	agent_id(Me,MyId) &
	 not .intend(create_exploration_gr) &
	 (MyId mod 4) == 1
  <- // create the exploration group
     if( not group(exploration_grp,_)[owner(Me)] ) {
	    ?group(team,TeamGroup); // get the team Id
        jmoise.create_group(exploration_grp,TeamGroup,G);
		.print("[explorationUSP.asl] Exploration group ",G," created")
     } else {
	    ?group(exploration_grp,G)[owner(Me)]
     };
     
     // adopt role explorer in the group
     !change_role(explorer,G);
     
     // create the scheme
     if ( not (scheme(explore_sch,S) & scheme_group(S,G)) ) {
        .print("[explorationUSP.asl] Creating exploration scheme for group ",G);
        -target(_,_); // remove target so that a new one is selected by near unvisited
        jmoise.create_scheme(explore_sch, [G])
     }.
     
+!create_exploration_gr.

-!create_exploration_gr
  <- !!create_exploration_gr.
  
  
/*
*	If I stop playing explorer, destroy the explore scheme/group I've created
*/

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
  
/*
* finds a place in the map and go to this place.
*/

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
     jia.near_least_visited(MeX, MeY, Area,TargetX, TargetY);
     .print("[exploration.asl] The nearest unvisited location is ",TargetX,",",TargetY);
     !!update_target(TargetX, TargetY).

+!goto_near_unvisited[scheme(Sch),mission(Mission)].
	 /* added by the pattern
	 .wait({+at_target}).
     !!goto_near_unvisited[scheme(Sch),mission(Mission)]
	 */
	 
{ end }


{ begin maintenance_goal("+pos(_,_,_)") }

+!follow_leader[scheme(Sch),mission(Mission),group(Gr)]
   : play(Leader, explorer, Gr) &
     .my_name(Me) &
     play(Me,scouter,Gr)
  <- .print("[explorationUSP.asl] I should follow the leader ",Leader);
     ?pos(MyX,MyY,_);
     ?ally_pos(Leader,LX,LY);
     ?ag_perception_ratio(AGPR);
     jia.dist(MyX, MyY, LX, LY, DistanceToLeader);
     
     // If I am far from him, go to him
     if( DistanceToLeader > (AGPR * 2) -3) {
        .print("[explorationUSP.asl] Approaching leader.");
     	!!update_target(LX,LY)
     } else {
        .print("[explorationUSP.asl] Being in formation with leader.");
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
  <- .print("[explorationUSP.asl] I should follow the leader (",Sch,"), BUT i don't know who it is! Try later.... ").


+!follow_leader
  <- .print("[explorationUSP.asl] I should follow the leader BUT i don't know who it is nor the Scheme! Try later.... ").
	 	 
{ end }	 

