////////////////////////////////////////////////////////////////////////////////
// Copyright (C) Gauthier Picard, 2010
// Use and distribution, without any warranties, under the terms of the
// GNU Library General Public License, readable in http://www.fsf.org/copyleft/lgpl.html
//
// Implementation of Asynchronous Backtraking algorithm (ABT) from Makoto 
// Yokoo's book (Distributed Constraint Satisfaction, Springer, 2000), Fig. 3.4,
// p.59, with a simplification in the backtrack procedure: all nogoods are not 
// computed and sent: only the agent's view is considered as a nogood 
// (see remark Section 3.4.1, p.60).
////////////////////////////////////////////////////////////////////////////////

{ include("abt-utils.asl") }

////////////////////////////////////////////////////////////////////////////////
//Initialisation:

@lstart[atomic]
+!start : domain(Xi,Domain) & agent_view(View) & consistent_values(Values,Xi,Domain,View,Nogoods) & current_value(V) <-
	.print(Xi," consistent values :",Values);
	?links(Xi,L);
	?domain(Xi,[D|_]);
	.print(Xi, " is setup and send ok? to ", L);
	!send_ok_to_links(D,L).
	
////////////////////////////////////////////////////////////////////////////////
// Messages
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//ok? message reception
//ok(Xi,Xj,Dj) is true when Xi receives a message informing that Xj'value is Dj

@lok[atomic]
+ok(Xi,Xj,Dj)[source(S)]: agent_view(View) & add_to_view([Xj,Dj],View,UView) <-
	-ok(Xi,Xj,Dj)[source(S)];
	?current_value(CV);
	.print(Xi, " (",CV,") receives ok?(",Xj,",",Dj,")");
	-+agent_view(UView);
	!check_agent_view.
	
////////////////////////////////////////////////////////////////////////////////	
//nogood message reception
//nogood(Xi,Xj,Nogood) is true when Xi receives the nogood Nogood from Xj

@lnogood[atomic]	
+nogood(Xi,Xj,Nogood)[source(S)]: nogood_list(Nogoods) & add_to_nogoods(Nogood,Nogoods,UNogoods) & current_value(V) <-
	-nogood(Xi,Xj,Nogood)[source(S)];
	.print(Xi, " (",V,") receives nogood(",Xj,",",Nogood,")");
	-+nogood_list(UNogoods);
	//!check_add_link(Nogood);
	!check_add_to_view(Nogood);
	-+old_value(V);
	!check_agent_view;
	?current_value(CV);
	if (V == CV) {
		.print(Xi, " (",CV,") sends ok?(",Xj,",",Xi,",",CV,") to ",Xj);
		.send(Xj,tell,ok(Xj,Xi,CV));
	}.
	
////////////////////////////////////////////////////////////////////////////////	
//add_link message reception
//add_link(Xi,Xj) is true when Xi receives a request from Xj to add a link from Xi to Xj

//request from an unknown agent:
@ladd_link01[atomic]
+add_link(Xi,Xj)[source(S)]: links(Xi,Links) & not contains(Links,Xj) <-
	-add_link(Xi,Xj)[source(S)];
	?current_value(CV);
	.print(Xi, " (",CV,") adds a link to ",Xj);
	-links(Xi,Links);
	+links(Xi,[Xj|Links]).

//request from an already known agent:
@ladd_link02[atomic]
+add_link(Xi,Xj)[source(S)]: links(Xi,Links) & contains(Links,Xj) <-
	-add_link(Xi,Xj)[source(S)];
	?current_value(CV);
	.print(Xi, " (",CV,") does not add a link to ",Xj).

////////////////////////////////////////////////////////////////////////////////
// check_agent_view procedure

//The agent's current_value is consistent with its view and nogoods: 
//the agent does nothing 
@lcheck_agent_view01[atomic]
+!check_agent_view: current_value(V) & agent_view(View) & nogood_list(Nogoods) & domain(Xi, Domain) & full_consistent(Xi,V,View,Nogoods) <-
	.print(Xi, " (",V,")'s view (",View,") is consistent with its current value ",V," and nogoods (",Nogoods,")").

//The agent's current_value is not consistent but there is a consistent value in the domain:
//the agent changes its current_value and inform outgoing links
@lcheck_agent_view02[atomic]
+!check_agent_view: current_value(V) & agent_view(View) & nogood_list(Nogoods) & domain(Xi, Domain) & consistent_values([D|_],Xi,Domain,View,Nogoods) & links(Xi,L) & D \== V <-
	.print(Xi, " (",V,")'s view (",View,") is not consistent but there is a solution (",D,") with nogoods (",Nogoods,")");
	-+current_value(D);
	!send_ok_to_links(D,L).
	
//The agent's current value is not consistent and there is no solution in the domain:
//the agent adds its view to nogood_list and backtracks
@lcheck_agent_view03[atomic]
+!check_agent_view: current_value(V) & agent_view(View) & nogood_list(Nogoods) & domain(Xi,Domain) & consistent_values([],Xi,Domain,View,Nogoods) & links(Xi,L) <-
	.print(Xi, " (",V,")'s view (",View,") is not consistent with its domain (",Domain,") and nogoods (",Nogoods,") and there is no solution : backtrack");
	!update_nogoods;
	!backtrack.
////////////////////////////////////////////////////////////////////////////////
// backtrack procedure
	
//The nogood_list contains []:
//there is no solution
@lbacktrack01[atomic]
+!backtrack: nogood_list(Nogoods) & contains(Nogoods,[]) <-
	.print("Backtrack : No solution !");
	.stopMAS.

//The agent's view is empty:
//The first is backtracking, so there is no solution
@lbacktrack04[atomic]
+!backtrack: agent_view([])<-
	.print("Backtrack : No solution !");
	.stopMAS.

//The agent's view is not empty and all nogood are not empty:
//the agent sends the nogood (its current_view) to Xj that has the lowest priority and removes (Xj,Dj) from its view
@lbacktrack02[atomic]
+!backtrack: domain(Xi,Domain) & current_value(Di) & agent_view(View) & lowest_priority_view_in_agent_view(Xj,View) & value_of(Xj,View,Dj) & remove([Xj,Dj],View,UView) <-
	?current_value(CV);
	.print(Xi, " (",CV,") sends a nogood (",View,") to ",Xj);
	.send(Xj,tell,nogood(Xj,Xi,View));
	-+agent_view(UView);
	!check_agent_view.
	
////////////////////////////////////////////////////////////////////////////////
// Some utilitary plans:

//Add the agent's view to nogoods:
+!update_nogoods: agent_view([]).
+!update_nogoods: nogood_list(Nogoods) & agent_view(View) & add_to_nogoods(View,Nogoods,UNogoods) <-
	-+nogood_list(UNogoods).

//Send ok? messages with value D to a list of agents:
+!send_ok_to_links(D,[]).
+!send_ok_to_links(D,[Xj|Xs]): .my_name(Xi) <-
	.print(Xi, " (",D,") sends ok?(",Xj,",",Xi,",",D,") to ",Xj);
	.send(Xj,tell,ok(Xj,Xi,D));
	!send_ok_to_links(D,Xs).

//Check whether it is necessary to add a new link from a nogood:
//agents that appear in nogood but not in agent's view are added to view
+!check_add_link(Nogood): links(Xi,L) & missing_values_from_links(L,Nogood,ToAdd) <-
	!add_links(ToAdd).

//Request to the listed agents Xk to add link from Xk to the agent
+!add_links([]).
+!add_links([[Xk,Dk]|Links]): domain(Xk,_) <-
	!add_links(Links).
+!add_links([[Xk,Dk]|Links]) <-
	.my_name(Xi);
	?current_value(CV);
	.print(Xi, " (",CV,") requests to add a link to ",Xk);
	.send(Xk,tell,add_link(Xk,Xi));
	!add_links(Links).

//Add the [Xj,Dj] pairs that appear in Nogood and not in View (but do not replace values for an already present Xj)
+!check_add_to_view(Nogood): domain(Xi,_) & agent_view(View) & missing_values_from_view(Xi,View,Nogood,ToAdd) & add_all_to_view(View,ToAdd,UView) <-
	-+agent_view(UView).

