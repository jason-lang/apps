// Check if number of boys is more than necessary.
too_much_boys(Boys, SizeCl)
  :- Boys > 3 & Boys > SizeCl.
//  :- Boys > 3 & 5*Boys > 4*SizeCl.

same_cluster(cluster(X1,Y1), cluster(X2,Y2))
:- jia.dist(X1,Y1,X2,Y2,Dist) &
   (Dist < 10).

+?num_ags(N)
<- N = 10.



{ begin maintenance_goal("+pos(_,_,_)") }

+!change_to_herding[scheme(Sch),mission(Mission),group(Gr)]
   : .my_name(Me) &
   	play(Me,explorer,Gr) &
   	pos(MyX,MyY,_) &
   	jia.preferable_cluster(MyX,MyY,L,S,N) &
   	.print("[herdingUSP.asl] LLL :",L) &
   	.list(L) &
   	.length(L) > 0 &
   	 not play(_,gatekeeper2,Gr) &
   	 not play(_,gatekeeper1,Gr) &
   	L = [pos(ClX,ClY),_] &
   	 jia.path_length(MyX, MyY, ClX, ClY,Dist , fences ) &
   	 .print("[herdingUSP.asl] LLL  Dist:",Dist) &
   	 Dist < 20
  <-	!create_herding_gr(Sch).
  	
   
  
  

+!change_to_herding[scheme(Sch),mission(Mission),group(Gr)].
	 
{ end }


+!create_herding_gr(ExplSch)
   : not .intend(create_herding_gr) &   // here i'll try to limit the herding group by calling just my scouters
   	.my_name(Me) &
   	play(Me,_,Gr) &
   	pos(MyX,MyY,_)
  <- .print("[herding.asl] Creating herding group.");
	.findall(Scouter,play(Scouter,scouter,Gr),Scouters);
//	!remove_old_commitments(ExplSch,Gr);
	// create the new  group
	?group(team,TeamId);
	jmoise.create_group(herding_grp, TeamId, HG);
	.print("[herding.asl] Herding group ",HG," created.");
	if(.list(Scouters) | .atom(Scouters)){
		.print("asking my scouters to change the role to herdboy: ", Scouters);
		.send(Scouters,achieve,change_role(herdboy,HG))
	};

//	!change_role(herder,HG);
	!change_to_herder(ExplSch,Gr,HG);
	.print("[herding.asl] Trying to change role in ",HG);
	?play(Me, NewRole,NewGroup);
	.print("[herdingUSP.als] Changed! now I'm: ",NewRole,"in ", NewGroup);
	// ask scouters to change role
	.print("[herding.asl] Asking ",Scouters," to adopt the herdboy role in ",HG);
	.broadcast(achieve,try_change_herding(pos(MyX,MyY))).

+!create_herding_gr(_).


+!change_to_herder(Sch,Gr,NewGr)
<-
 !remove_old_commitments(Sch,Gr);
 .print("Trying to be a herder");
 jmoise.adopt_role(herder,NewGr).

+!remove_old_commitments(Sch,Gr)
: .my_name(Me) & 
  play(Me,Role,Gr)
<- 
	.drop_desire(_[scheme(Sch),mission(Mission)]);
	jmoise.remove_scheme(Sch);
	while( commitment(Me,M,Sch) ) {
        	.print("[usp.asl] Removing my mission ",M," in ",Sch);
        	jmoise.remove_mission(M,Sch)
	};
	jmoise.remove_role(Role,Gr);
	jmoise.remove_group(Gr);
	.print("Old commitments Removed!").
  

/**
* I'm doing nothing, so try to be a herder.
*/

+!try_change_herding(pos(Lx,Ly))[source(Leader)]
: .my_name(Me) &
  not play(Me,herdboy,_) &
  not play(Me,herder,_) &
  not_play_gk(Me) &
  pos(MyX,MyY,_) &
  jia.path_length(MyX, MyY, Lx, Ly, Dist , fences )
  <- .send(Leader,tell,freeAg(Me)).

+!try_change_herding(_).
/**
* there's someone doing nothing 
*/


+freeAg(_)
: .my_name(Me) & 
  not play(Me,herder,_)
<- .print("I'm not a Herder Anymore").

+!join_us_as_herdboy(Gr)
: .my_name(Me) &
  not play(Me,herdboy,_) &
  not play(Me,herder,_) &
  not_play_gk(Me) 
<- !change_role(herdboy,Gr).

+!join_us_as_herdboy(_).
/**
*	Recruit Agents
*/


{ begin maintenance_goal("+pos(_,_,_)") }

+!recruit[scheme(Sch),mission(Mission),group(Gr)]
: freeAg(Ag) &
  .count(play(_,_,Gr),NAg) &
  num_ags(NAg2) &
  NAg < NAg2
<- -freeAg(Ag);
	.print("Agent ",Ag," should became herdboy");
	.send(Ag,achieve,join_us_as_herdboy(Gr));
	!recruit.
	
+!recruit
 : .count(play(_,_,Gr),NAg) &
 num_ags(NAg2) &
  NAg < NAg2 &
  pos(MyX,MyY,_)
<- .print("I need more herdboys! NAg = ",NAg);
 .broadcast(achieve,try_change_herding(pos(MyX,MyY)));
 .wait({+pos(_,_,_)});
 .wait({+pos(_,_,_)});
 .wait({+pos(_,_,_)}).



+!recruit
<- .print("My group has the maximum number of herdboys, not going to ask for more").
{ end }


// If I start playing herder in a group that has no scheme, create the scheme
+play(Me,herder,G)
   : .my_name(Me) &
     not scheme_group(_,G)
  <- jmoise.create_scheme(herd_sch, [G]);
     +group_leader(G,Me);
     .broadcast(tell, group_leader(G,Me)).
     
-play(Me,herder,_)
   : .my_name(Me)
  <- .wait({+pos(_,_,_)});
	-cluster(_,_);

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
	 

   

{ begin maintenance_goal("+pos(_,_,_)") }
+!release_boys.  
{ end }

{ begin maintenance_goal("+pos(_,_,_)") }
+!define_formation
: pos(MyX,MyY,_) & 
  not .intend(define_formation) &
  .my_name(Me) &
  play(Me,herder,Gr) &
  jia.preferable_cluster(MyX,MyY,L,S,N) &
  .list(L) &
  .length(L) > 0 &
  L = [pos(ClX,ClY),_] &
  S = [Size,_] &
  .count(play(_,_,Gr),NAg) &
  jia.position_to_cluster( ClX, ClY, NAg, Formation)
<-  .findall(P, play(P,herdboy,Gr) | play(P,herder,Gr), Agents);
    -+cluster(ClX,ClY);
    .print("Formation is: ",Formation," and Agents are: ",Agents);
    !alloc_all(Agents,Formation).

+!define_formation.  
{ end }

 +!alloc_all([],[]).
 +!alloc_all([],L) <- .print("ooo there is no agent for the formation ",L).
 +!alloc_all(G,[]) <- .print("ooo there is no place in the formation for ",G).
 +!alloc_all(Agents,[pos(X,Y)|TLoc])
 	<- !find_closest(Agents,pos(X,Y),HA);
  	   .print("ooo Allocating position ",pos(X,Y)," to agent ",HA);
	    ?agent_id(HA,HAId);
           .send(usp1,tell,target_other(HAId,X,Y));
           .print("Sending request to ",HA,"(",HAId,") to go to ",X,",",Y);
 	   .send(HA,tell,target(X,Y));
 	   .delete(HA,Agents,TAg);
 	   !alloc_all(TAg,TLoc).
 
 +!find_closest(Agents, pos(FX,FY), NearAg) // find the agent near to pos(X,Y)
 	<- .my_name(Me);
 	   .findall(d(D,Ag),
           .member(Ag,Agents) & (ally_pos(Ag,AgX,AgY) | Ag == Me & pos(AgX,AgY,_)) & jia.path_length(FX,FY,AgX,AgY,D),
                            Distances);
           .min(Distances,d(_,NearAg)).



// Merge!
+!merge(OtherGr)
:  not .intend(create_herding_gr(_)) &   // here i'll try to limit the herding group by calling just my scouters
   	.my_name(Me) &
   	play(Me,_,Gr) &
   	pos(MyX,MyY,_)
<- .findall(HB,play(Scouter,herdboy,Gr),HBs);
   if(.list(HBs) | .atom(HBs)){
     .print("asking my herdboys to change the group: ", HBs);
     .send(HBs,achieve,change_role(herdboy,OtherGr))
   };
   !remove_old_commitments(Sch,Gr);
   jmoise.adopt_role(herdboy,OtherGr).

+!merge.




{ begin maintenance_goal("+pos(_,_,_)") }
+!check_merge
     : .my_name(Me) &
       play(Me, herder, Gr) &
       cluster(X,Y) &
       .count(play(_,_,Gr),NAg) &
       num_ags(NAg2) &
       NAg < NAg2
   <-  for( group_leader(Go, L) & Me < L & not play(L,herdboy,Gr)) { 
	.send(L, askOne, cluster(_), cluster(Xo,Yo));
	if(same_cluster(cluster(X1,Y1), cluster(X2,Y2))){
		.send(L,achieve, merge(Gr))
	}

       }.

 +!check_merge.
{ end }






{ begin maintenance_goal("+pos(_,_,_)") }
+!be_in_formation.  
{ end }

{ begin maintenance_goal("+pos(_,_,_)") }
+!start_open_corral.  
{ end }




