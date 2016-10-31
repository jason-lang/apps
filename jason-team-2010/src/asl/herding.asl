/* -- plans for herding phase -- */

// Check if number of boys is more than necessary.
too_much_boys(Boys, SizeCl)
  :- Boys > 3 & Boys > SizeCl.
//  :- Boys > 3 & 5*Boys > 4*SizeCl.

not_gatekeeper(Boy)   // if he isn't a gatekeeper1 nor a gatekeeper2, he isn't a gatekeeper! 
:- not play(Boy, gatekeeper1,_) & not play(Boy, gatekeeper2,_).

dist_cow_near_corral(Dist) :- 
     corral_center(CorX, CorY) &
	cluster_group(_, XCl, YCl, Size, _)[source(self)] &
     jia.dist(XCl,YCl,CorX,CorY,D) & 
     corral_half_width(CW) & 
     Dist = D - CW - Size/2.


/* -- plans for herding groups creation -- */

+!create_herding_gr
   : not .intend(create_herding_gr) &   // here i'll try to limit the herding group by calling just my scouters
   	.my_name(Me) &
   	play(Me,_,Gr)
  <- .print("[herding.asl] Creating herding group.");

	.findall(Scouter,play(Scouter,scouter,Gr),Scouters);

	// create the new  group
	?group(team,TeamId);
	jmoise.create_group(herding_grp, TeamId, HG);
	 .print("[herding.asl] Herding group ",HG," created.");
	 
	!change_role(herder,HG);

	// ask scouters to change role
	// .print("[herding.asl] Asking ",BoysCand," to adopt the herdboy role in ",HG);
	.send(Scouters,achieve,change_role(herdboy,HG)).

+!create_herding_gr.
	

+!update_n_of_clusters_to_be_herded(Number)    												// NEVER USED!
   : .my_name(gaucho1)
  <- -+n_of_clusters_to_be_herded(Number);
	.print("[herding.asl] bem depois! N=",Number).
	 
// If I start playing herder in a group that has no scheme, create the scheme
+play(Me,herder,G)
   : .my_name(Me) &
     not scheme_group(_,G)
  <- jmoise.create_scheme(herd_sch, [G]);
     +group_leader(G,Me);
     .broadcast(tell, group_leader(G,Me)).
	 
// If I stop playing herder, destroy the herding groups I've created
-play(Me,herder,_)
   : .my_name(Me)
  <- .wait({+pos(_,_,_)});

	for( scheme(herd_sch,S)[owner(Me)] | scheme(pass_fence_sch,S)[owner(Me)]) {
	    .print("[herding.asl] Removing scheme ",S);
	    jmoise.remove_scheme(S)
	 };
	 for( group(herding_grp,G)[owner(Me)] ) {
	    -group_leader(G,Me);
        .broadcast(untell, group_leader(G,Me));
        .print("[herding.asl] Removing the group ",G);
	    jmoise.remove_group(G)
	 }.
	 
// If I stop playing herdboy (because the group was destroied by the herder),
// I should try yo create my new exploration group
/* This plan does not work with merging!
-play(Me,herdboy,_)
   : .my_name(Me)
  <- .print("ooo I do not play herdboy anymore, try to play a role in an exploration group.");
     !explore.
*/
  
/* -- plans for the goals of role herder -- */

{ begin maintenance_goal("+pos(_,_,_)") }

+!recruit[scheme(Sch),mission(Mission),group(Gr)]
  <- .print("[herding.asl] I should revise the size of the cluster and recruit!");
     .findall(Ag, group(exploration_grp,_)[owner(Ag)],Explorers);
     -+recruit_finished(false);
     for ( .member(E,Explorers) ) {
        .send(E,askAll,play(_, scouter, _), LBoys); // LBoys = play(Ag,scaouter,Gr)[0..]
        for ( .member(play(S, _, _), LBoys) ) { // for(Agent S: LBoys)
            if (pos(MyX,MyY,_) &
                ally_pos(S,SX,SY) &
                jia.path_length(SX, SY, MyX, MyY, _, fences) &
                cluster_group(Gr, XCl, YCl, SizeCl, LengthAg) &
                recruit_finished(false)) {
                
                .print("[herding.asl] Trying to recruit ",S, " to my group ",Gr, ", Boys=",LengthAg, ", SizeCl=", SizeCl);
                if (not too_much_boys(LengthAg+1, SizeCl)) {
                    .print("[herding.asl] Recruiting ",S, " to my group ",Gr);
                    .send(S, achieve, adopting_role(herdboy,Gr));
                    -+cluster_group(Gr, XCl, YCl, SizeCl, LengthAg+1)
                } else {
                    -+recruit_finished(true)
                }
            }
        };
        if (pos(MyX,MyY,_) &
            ally_pos(E,EX,EY) &
            jia.path_length(EX, EY, MyX, MyY, _, fences) &
            cluster_group(Gr, XCl, YCl, SizeCl, LengthAg) &
            recruit_finished(false)) {
            
            .print("[herding.asl] Trying to recruit ",E, " to my group ",Gr, ", Boys=",LengthAg, ", SizeCl=", SizeCl);
            if (not too_much_boys(LengthAg+1, SizeCl)) {
                .print("[herding.asl] Recruiting ",E, " to my group ",Gr);
                .send(E, achieve, adopting_role(herdboy,Gr));
                -+cluster_group(Gr, XCl, YCl, SizeCl, LengthAg+1)
            } else {
                -+recruit_finished(true)
            }
        }
     };
     -recruit_finished(_);
     .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)}).

{ end }


+!adopting_role(Role,G)
  <- !quit_all_missions_roles;
     jmoise.adopt_role(Role,G).

/*+!check_merge
    : .my_name(Me) &
	  play(Me, herder, Gi) &
      //.count(play(_,_,Gi), N) & N < 3 & // only merge small group
	  current_cluster(MyC)
  <-  // for all other groups
      for(group_leader(Gj, L)  & Me < L & L \== Me & not play(L,herdboy,Gi)) { // 
	     .print("ooo Checking merging with ",Gj);
         // ask their clusters
         .send(L, askOne, current_cluster(_), current_cluster(TC));
		 .intersection(MyC,TC,I);
		 
		 if (.length(I) > 0) {
            //MyC = [pos(MyCX,MyCY)|_];
            //TC  = [pos(TCX,TCY)|_];
            //?corral_center(CorralX, CorralY);
            //jia.path_length(MyCX,MyCY,CorralX,CorralY,MCD);
            //jia.path_length(TCX,TCY,CorralX,CorralY,TCD);
            //.print("ooo check merging: my distance to corral = ",MCD," other group distance = ",TCD);
            //if (MCD <= TCD) {
               .print("ooo merging my herding group ",Gi," with ",Gj, " lead by ",L, " common cows are ",I);
               .send(L,achieve, change_role(herdboy,Gi))
            //}
		 } else {
		    .print("ooo no common cows, so no merging, my cows \n",MyC,"\n",TC)
		 }
	  };
	  .wait(2000). // give some time for them to adopt the roles before check merging again
+!check_merge.
*/	 	 

{ begin maintenance_goal("+pos(_,_,_)") }

+!release_boys[group(Gr)]
   : .my_name(Me) &
     play(Me, herder, Gr)
  <- .print("[herding.asl] release_boys Checking if it is necessary to release boys!");
     
     .findall(Boy, play(Boy, herdboy, Gr), Boys);
     
     for ( .member(B, Boys) ) {
         if (cluster_group(Gr, XCl, YCl, SizeCl, LengthAg) &
             too_much_boys(LengthAg, SizeCl)) {
			if (has_to_release_boys(yes)) {
				-+has_to_release_boys(no);
				.print("[herding.asl] release_boys Releasing agent ", B, " from herding group and asking him to go explore (Boys=", LengthAg, ", SizeCl=", SizeCl, ")!");
  			     .send(B, achieve, changing_to_exploring);
				-+cluster_group(Gr, XCl, YCl, SizeCl, LengthAg-1)
			} else {
				-+has_to_release_boys(yes)
			}
         }
     };
     .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)});
     .wait({+pos(_,_,_)}).

+!release_boys[group(Gr)].
     
-!release_boys(_,_,_)[error_msg(M),code(C)]
  <- .print("[herding.asl] release_boys Error: ", C, " - ", M).

{ end }

+!changing_to_exploring
  <- !quit_all_missions_roles;
     !explore.

{ begin maintenance_goal("+pos(_,_,_)") }

+!define_formation[scheme(Sch),mission(Mission), group(Gr)]
   : .my_name(Me) &
     play(Me, herder, Gr) &
	not .intend(define_formation)
  <- .wait({+pos(_,_,_)});
     .print("[herding.asl] define_formation-1 I should define the formation of my group ",Gr);
  	 jia.getclusters(N, Clusters, Sizes);
  	 if (N > 0) {
	     ?pos(XMe,YMe,S);
	     //.print("[herding.asl] define_formation-2 My position is (",XMe,",",YMe,") and I have ",N, " possible clusters at the step ",S, ", Clusters=",Clusters, ", Sizes=",Sizes);
	     -+clusters(Clusters, Sizes);
	     
	     .findall(Boy, play(Boy, herdboy,Gr) & not_gatekeeper(Boy) , Boys);      // gustavo: nao considerando 
	     																		// os gatekeepers, se nao eles vao sair do gate.
	     GrFor = [Me|Boys];
	     -+soma(XMe,YMe);
	     for ( .member(B,Boys) ) {
			.send(B, askOne, pos(_,_,_), Reply);
			Reply = pos(XB,YB,_);
			?soma(SX,SY);
			-+soma(SX+XB,SY+YB)
	     };
	     ?soma(SX,SY);
	     XGr = SX / .length(GrFor);
	     YGr = SY / .length(GrFor);
	     -soma(_,_);
	     
	     if (cluster_group(Gr, XClAtual, YClAtual, SC, LA)[source(self)]) {
            jia.preferable_cluster(XGr,YGr,XClAtual,YClAtual,PosClusters,SizeClusters,NClusters);
            -+cluster_group(Gr, XClAtual, YClAtual, SC, LA)
         } else {
            jia.preferable_cluster(XGr,YGr,PosClusters,SizeClusters,NClusters);
            -cluster_group(_,_,_,_,_)
         };      
        
        	.print("[herding.asl] define_formation-2 My position is (",XMe,",",YMe,") and I have ",NClusters, " possible clusters at the step ",S, ", Clusters=",PosClusters, ", Sizes=",SizeClusters);
         //!release_boys(Gr, Boys, SizeChosen);
	     //?grForNovo(GrForNovo);
         //-grForNovo(_);
	     GrForNovo = GrFor;
	     
	     .findall(h(GHerder,Herder), group_leader(GHerder, Herder) & Herder \== Me, Herders);
		-+finished(false);
		-+allClusters([]);
		for ( .member(h(GH,H),Herders)) {
			if (finished(false)) {
			    .send(H, askOne, cluster_group(GH,_,_,_,_), Reply, 200);
			    .print("[herding.asl] define_formation-3a Reply=",Reply);
				if (Reply == timeout) {
					-+finished(true)
				} else {
				    	if (Reply \== false) {
				    		?allClusters(AH);
				    		-+allClusters([Reply|AH]);	
					}
				}
			}
		}
		?allClusters(AH);
		.print("[herding.asl] define_formation-3b allClusters=",AH);

		-+sizeClusters(SizeClusters);
		
		for ( .member(pos(XClChosen,YClChosen),PosClusters) ) {
			if (finished(false)) {

				?sizeClusters([SizeChosen|Others]);
				-+sizeClusters(Others);
				if ((SizeChosen <= 15) & (XClChosen \== 0) & (YClChosen \== 0) & (SizeChosen \== 0)) {

					.print("[herding.asl] define_formation-4 Possible chosen cluster has center (", XClChosen, ",", YClChosen, "), size ", SizeChosen, " and group has ", .length(GrForNovo), " agents");
	
					-fullCluster;
					for ( .member(h(GH,H),Herders) & .member(cluster_group(GH,XClH,YClH,_,Length),AH)) {
					   if (finished(false) & not fullCluster) {
						    jia.dist(XClH,YClH,XClChosen,YClChosen,DistCl);
						    if (DistCl <= 6 & Gr \== GH) {
							   if (not too_much_boys(.length(GrForNovo)+Length, SizeChosen)) {
								   -+finished(true);
								   if (.length(GrForNovo) < Length | ((.length(GrForNovo) == Length) & (Gr < GH))) {
									   .print("[herding.asl] define_formation-6a Merging ",Gr," with ",GH);
									   -cluster_group(_, _, _, _, _);
									   !merge_groups(H, GH,XClChosen,YClChosen,SizeChosen,.length(GrForNovo)+Length)
								   }
							   } else {
								   -+fullCluster
							   }
						    }
						}
					};
					if (finished(false) & not fullCluster) {
						-+finished(true);
						-+cluster_group(Gr, XClChosen, YClChosen, SizeChosen, .length(GrForNovo));
						jia.position_to_cluster(XClChosen,YClChosen,.length(GrForNovo),L);
						.print("[herding.asl] define_formation-6b Formation is ", L, " for agents ", GrForNovo, " in cluster with center in (", XClChosen, ",", YClChosen, ")");
						!!alloc_all(GrForNovo,L)
					}
				} else {
					-+finished(true)
				}
			}
		};
		if (finished(false)) {
			-+finished(true);
			//-cluster_group(_, _, _, _, _);
			.print("[herding.asl] define_formation-6c Changing herding group ",Gr," to exploring group")/*;
			!change_to_exploring_c(Gr)*/
		};
		-sizeClusters(_);
		-finished(_)
	 } else {
        .print("[herding.asl] define_formation No cluster to define the formation! Going to explore!");
        -cluster_group(_, _, _, _, _);
        !change_to_exploring_c(Gr)
     };
     if (not cluster_group(_,_,_,_,_)) {
        .print("[herding.asl] cluster_group=null")
     } else {
        ?cluster_group(A,B,C,D,E);
        .print("[herding.asl] cluster_group=(",A,", ",B,", ",C,", ",D,", ",E, ")")
     }.
	
+!define_formation[scheme(Sch),mission(Mission), group(Gr)].
 
{ end }

+!merge_groups(GrLeader, Gr,XCl,YCl,Size,GrLength)
  <-  //atualiza o numero de agentes no hrd grp GrH
	 .send(GrLeader, achieve, update_cluster_group(Gr,XCl,YCl,Size,GrLength));
	 !!change_role(herdboy,Gr).

+!update_cluster_group(Gr,XCl,YCl,Size,GrLength)
  <- -+cluster_group(Gr,XCl,YCl,Size,GrLength).

// version "near agent of each position 
+!alloc_all([],[]).

+!alloc_all([],L)
  <- .print("[herding.asl] There is no agent for the formation ", L).
  
+!alloc_all(G,[])
  <- .print("[herding.asl] There is no place in the formation for ", G).
  
+!alloc_all(Agents,[pos(X,Y)|TLoc])
  <- .my_name(Me);
     !find_closest(Agents,pos(X,Y),HA);
     .print("[herding.asl] Allocating position ",pos(X,Y)," to agent ",HA);
     if (HA == Me) {
        !!update_target(X,Y)
     } else {
        .send(HA,achieve,update_target(X,Y))
     };
	 .delete(HA,Agents,TAg);
	 if (boy_beyond_fence(X,Y,FX,FY)) {
        +has_boy_beyond_fence(FX,FY)
     };
     !alloc_all(TAg,TLoc).

+!find_closest(Agents, pos(FX,FY), NearAg) // find the agent near to pos(X,Y)
  <- .my_name(Me);
     .findall(d(D,Ag),
              .member(Ag,Agents) & (ally_pos(Ag,AgX,AgY) | Ag == Me & pos(AgX,AgY,_)) & jia.path_length(FX,FY,AgX,AgY,D),
			  Distances);
	 .min(Distances,d(_,NearAg)).

+!update_target(X,Y)
  <- -+target(X,Y).

/* 
// version "near  place of the agent"
+!alloc_all([],[]).
+!alloc_all(G,[]) <- .print("ooo there is no place in the formation for ",G).
+!alloc_all([HA|TA],LA)
  <- !find_closest(HA,LA,pos(X,Y),NLA);
     .print("ooo Alocating position ",pos(X,Y)," to agent ",HA);
     //.send(HA,untell,target(_,_));
     .send(HA,tell,target(X,Y));
	 //-+alloc_target(HA,Alloc);
     !alloc_all(TA,NLA).

+!find_closest(Ag, ListPos, MinDist, Rest) // find the location in ListPos nearest to agent Ag
  <- ?ally_pos(Ag,X,Y);
     //.print("ooo try to alloc ",Ag," in ",X,Y," with ",ListPos);
     ?calc_distances(ListPos,Distances,pos(X,Y));
	 .print("Distances for ",ag_pos(Ag,X,Y)," are ",Distances);
	 .min(Distances,d(_,MinDist));
	 .delete(MinDist,ListPos,Rest).
	 //!closest(ListPos,[],[MinDist|Rest],pos(X,Y),9999).

calc_distances([],[],_) :- true.
calc_distances([pos(Fx,Fy)|TP], [d(D,pos(Fx,Fy))|TD], pos(AgX,AgY))
  :- jia.path_length(Fx,Fy,AgX,AgY,D) & calc_distances(TP, TD, pos(AgX,AgY)).


+!closest([],S,S,_,_).
+!closest([pos(XH,YH)|T],Aux,S,pos(XP,YP),LD)
  :  jia.path_length(XH,YH,XP,YP,D) & D < LD 
  <- !closest(T,[pos(XH,YH)|Aux],S,pos(XP,YP),D).
+!closest([pos(XH,YH)|T],Aux,S,pos(XP,YP),LD)
  <- .concat(Aux,[pos(XH,YH)],Aux2);
     !closest(T,Aux2,S,pos(XP,YP),LD).
*/


/* -- Open Corral -- */

{ begin maintenance_goal("+pos(_,_,_)") }

+!start_open_corral[scheme(Sch),mission(Mission),group(Gr)]
   : switch(X,Y) & jia.is_corral_switch(X,Y) & // get the switch of our corral
     .print("[herding.asl] start_open_corral Initating test open corral for switch ",X,",",Y) & 
     not scheme(open_corral,SchId) & // scheme_group(SchId, _)) & // there is no scheme to open
     //pos(MeX, MeY, _) & jia.path_length(MeX,MeY,X,Y,Dist) &
     dist_cow_near_corral(Dist) &
     .print("[herding.asl] start_open_corral Near cow distance from corral center is ",Dist) &
     Dist < 12 & 
     .findall(Boy, play(Boy, herdboy, Gr), Cand) &
     .print("[herding.asl] start_open_corral Candidates for porter1 in group ",Gr, " are ",Cand) & 
     Cand \== []
  <- .print("[herding.asl] start_open_corral I should start an open corral scheme for group ",Gr);
     !find_closest(Cand,pos(X,Y),HA);
     .print("[herding.asl] Nearest agent of corral is ",HA);
     jmoise.create_scheme(open_corral, [Gr], SchId);
     ?ally_pos(HA,AX,AY);
     jia.switch_places(X,Y,AX,AY,PX,PY,_,_);
     .my_name(Me);
     jmoise.set_goal_arg(SchId,goto_switch1,"X",PX);
     jmoise.set_goal_arg(SchId,goto_switch1,"Y",PY);
     jmoise.set_goal_arg(SchId,end_open_corral,"Boss", Me);
     .send(HA, achieve, change_role(gatekeeper1, Gr));
     .wait({ +pos(_,_,_) }). // wait one extra step so that HA can adopt the role and the next plan does not trigger
     
+!start_open_corral[scheme(Sch),mission(Mission),group(Gr)]
   : // if my open_corral scheme has no players, remove it
     .my_name(Me) & 
     scheme(open_corral,SchId)[owner(Me)] & sch_players(SchId,0)
  <- .print("[herding.asl] start_open_corral Removing scheme ",SchId," since no agent belongs to it");
     jmoise.remove_scheme(SchId).
     
+!start_open_corral[scheme(Sch),mission(Mission),group(Gr)].

{ end }

{ begin maintenance_goal("+pos(_,_,_)") }

/*
+!end_open_corral[scheme(Sch),mission(Mission),group(Gr)]
   : // if the leader is too far, remove the sch
     group(_,Gr)[owner(O)] & 
     ally_pos(O,OX,OY) &
     pos(MeX, MeY, _) &
     jia.path_length(MeX,MeY,OX,OY,Dist) & 
     .print("yyy vvv my distance to leader is ",Dist) & 
     Dist > 20 & 
     not (ally_pos(_,AlX,AlY) & jia.corral(AlX,AlY) & .print("yyy vvv but there is an agent in the corral")) // no ally in corral
  <- !!change_role(herdboy,Gr);
     jmoise.remove_scheme(Sch).
*/

+!end_open_corral(_)[scheme(Sch),mission(Mission),group(Gr)]
   : // if I am too far from switch (because I discovered some obstacle)
     pos(MeX, MeY, _) &
     goal_state(Sch,goto_switch1(SX,SY),_) & 
     jia.path_length(MeX,MeY,SX,SY,Dist) & 
     .print("[herding.asl] end_open_corral My distance to switch is ",Dist) & 
     Dist > 20
  <- !!change_role(herdboy,Gr);
     jmoise.remove_scheme(Sch).

+!end_open_corral(Boss)[scheme(Sch),mission(Mission),group(Gr)]
  <- .send(Boss, askOne, cluster_group(Gr,_,_,_,_), Reply, 300);
  	if (Reply == false | (not group(_,Gr))) {
		.print("[herding.asl] end_open_corral No open curral group anymore ");
	  	!!change_role(herdboy,Gr);
		jmoise.remove_scheme(Sch)
  	};
  	.send(Boss, askOne, dist_cow_near_corral(Dist), dist_cow_near_corral(Dist), 300);
     .print("[herding.asl] end_open_corral Near cow distance from corral center is ",Dist);
     if (Dist > 20) {
     	!!change_role(herdboy,Gr);
		jmoise.remove_scheme(Sch)
     };
  	.wait({+pos(_,_,_)}).

/*+!end_open_corral(Boss)[scheme(Sch),mission(Mission),group(Gr)]
  <- .abolish(cow_near_corral(_));
     .send(Boss, askOne, cow_near_corral(_) ).*/

{ end }



//+!goto_switch(X,Y)[scheme(Sch)]
//  <- !goto_switch(X,Y,Sch,goto_switch). // the basic implementation of goto switch (pass_fence.asl)
     	
/* -- Change to exploring -- */

+!change_to_exploring_c(Gr)
  <- .print("[herding.asl] Changing herding group ",Gr," to exploring group");
	 .my_name(Me);
     .findall(P, play(P,_,Gr) & P \== Me, ListBoys);
     !!create_exploration_gr;
     .wait({+pos(_,_,_)});
     .findall(Gr, group(exploration_grp,Gr)[owner(Me)],MyGroup);
	 .send(ListBoys, achieve, changing_to_exploring).
     /*if (.length(MyGroup) >= 1) {
        MyGroup = [NewGr|_];
        .print("[herding.asl] vvvv Correto!! NewGr=",NewGr);
        // ask helpers in my group to change the role
	    .send(ListBoys, achieve, quit_all_missions_roles)
     } else {
        .print("[herding.asl] vvvv Erro!! .length(MyGroup)=",.length(MyGroup))
     }.*/

-!change_to_exploring_c[error_msg(M),code(C)]
  <- .print("[herding.asl] change_to_exploring Error: ", C, " - ", M).


/* -- plans for the goals of all roles (herder and herdboy) -- */

// This goal behaviour is set by the message "tell target" of the leader of the group
+!be_in_formation[scheme(Sch),mission(Mission)]
  <- .print("[herding.asl] I should be in formation!").
     //.suspend.

