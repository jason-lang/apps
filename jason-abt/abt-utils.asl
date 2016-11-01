////////////////////////////////////////////////////////////////////////////////
// Copyright (C) Gauthier Picard, 2010
// Use and distribution, without any warranties, under the terms of the
// GNU Library General Public License, readable in http://www.fsf.org/copyleft/lgpl.html
//
// Some utilitary rules for manipulating lists, assignment lists (views and 
// nogoods), and checking consistency for ABT like algorithms
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Lists:

//remove/3
//remove(V,L,UL) is true if UL is equal to L without V
remove(V,[],[]).
remove(V,[V|L],L).
remove(V,[W|L],[W|UL]):- V \== W & remove(V,L,UL).

//contains/2
//contains(L,X) is true if L contains at least one X 
contains([X|_],X).
contains([_|L],X):- contains(L,X).

//includes/2
//includes(L1,L2) is true if all elements of L2 are in L1
includes(_,[]).
includes(L,[H|Q]):- contains(L,H) & includes(L,Q).

////////////////////////////////////////////////////////////////////////////////
//Assignment Lists (Views and Nogoods):

//value_of/3
//value_of(X,L,D) is true if D is the value of X in the assignment list L
value_of(X,[[X,D]|L],D).
value_of(X,[H|L],D):- value_of(X,L,D).

//contains_entry/2
//contains_entry(L,X) is true if L is an assignment list and X is on entry in this list
contains_entry([[Xi,_]|L],Xi).
contains_entry([_|L],Xi):- contains_entry(L,Xi).

//add_to_view/3
//add_to_view([Xi,Di],L1,L2) is true if L2 is the same assignment list than the assignment list L1 with a new value Di for Xi
add_to_view([Xi,Di],[],[[Xi,Di]]).
add_to_view([Xi,Di],[[Xi,Dj]|L],[[Xi,Di]|L]).
add_to_view([Xi,Di],[[Xj,Dj]|L],[[Xj,Dj]|L2]):- Xi \== Xj & add_to_view([Xi,Di],L,L2).

//add_all_to_view/3
//add_all_to_view(V,L1,L2) is true if L2 is the same list than L1 with all new values from V
add_all_to_view([],L1,L1).
add_all_to_view([H|L],L1,L2):- add_to_view(H,L1,L3) & add_all_to_view(L,L3,L2). 

//add_to_nogoods/3
//add_to_nogoods(Ng,Ngs1,Ngs2) adds a nogood Ng in a nogood list Ngs1, resulting in Ngs2 list, only if it is not already in (nogoods are equal if they are reciprocally compatible)
add_to_nogoods(Nogood,[],[Nogood]).
add_to_nogoods(Nogood,[Ng|Nogoods],[Ng|Nogoods]):- compatible(Ng,Nogood) & compatible(Nogood,Ng).
add_to_nogoods(Nogood,[Ng|Nogoods],[Ng|Ngs]):- add_to_nogoods(Nogood,Nogoods,Ngs).

//compatible/2
//compatible(Nogood,View) is true if all variables in Nogood have the same values in the View
compatible([],View).
compatible([[Xi,Di]|Nogood],View):- contains_entry(View,Xi) & value_of(Xi,View,Di) & compatible(Nogood,View).

//uncompatible/2
//uncompatible(Nogoods,View) is true if all Nogoods are not compatible with View
uncompatible([],_).
uncompatible([Nogood|Nogoods],View):- not compatible(Nogood,View) & uncompatible(Nogoods,View).

//get_agents_from_view/2
//get_agents_from_view(Agents,View) is true if Agents is the list of all agents in View
get_agents_from_view([],[]).
get_agents_from_view([[Xi,_]|View],[Xi|Agents]):- get_agents_from_view(View,Agents).

//lowest_priority_view_in_agent_view/2
//lowest_priority_view_in_agent_view([Xj,Dj],View) is true if Xj is the lowest priority agent in View with the value Dj
lowest_priority_view_in_agent_view(Xi,View):- get_agents_from_view(View,Agents) & .max(Agents,Xi).

//missing_values_from_links/3
//missing_values_from_links(Links,L,UL) is true if UL is the assignment list containing all assignments [Xi,Di] from L where Xi is not in Links  
missing_values_from_links(Links,[],[]).
missing_values_from_links(Links,[[Xi,Di]|L],[[Xi,Di]|UL]):- not contains(Links,Xi) & missing_values_from_links(Links,L,UL).
missing_values_from_links(Links,[[Xi,Di]|L],UL):- contains(Links,Xi) & missing_values_from_links(Links,L,UL).

//missing_values_from_view/4
//missing_values_from_view(Xi,View,U,UL) is true if UL is the assignment list containing all assignments [Xj,Dj] from L where Xj is not an entry in View and Xi \== Xj   
missing_values_from_view(Xi,View,[],[]).
missing_values_from_view(Xi,View,[[Xi,_]|L],UL):- missing_values_from_view(Xi,View,L,UL).
missing_values_from_view(Xi,View,[[Xj,Dj]|L],[[Xj,Dj]|UL]):- Xi \== Xj & not contains_entry(View,Xj) & missing_values_from_view(Xi,View,L,UL).
missing_values_from_view(Xi,View,[[Xj,Dj]|L],UL):- contains_entry(View,Xj) & missing_values_from_view(Xi,View,L,UL).

////////////////////////////////////////////////////////////////////////////////
// Consistency Checking: 

//full_consistent/4
//full_consistent(Agent,Value,View,Nogoods) is true if Value is consistent with Agent's View and all Nogood are not compatible with [Agent,Value]|View
full_consistent(Agent,Value,View,Nogoods):- consistent(Value,View) & uncompatible(Nogoods,[[Agent,Value]|View]).

//consistent/2
//consistent(D,L) is true is D has no conflict with every value in assignment list L
consistent(D,[]).
consistent(D,[[Xj,V]|L]):- not conflict(D,V) & consistent(D,L).

//consistent_values/5
//consistent_values(Values,Agent,Domain,View,Nogoods) is true if Values is the set of all consistent values in Domain wrt the View
consistent_values([],_,[],_,_).
consistent_values([V|L],Agent,[V|Domain],View,Nogoods):- full_consistent(Agent,V,View,Nogoods) & consistent_values(L,Agent,Domain,View,Nogoods).
consistent_values(L,Agent,[V|Domain],View,Nogoods):- not full_consistent(Agent,V,View,Nogoods) & consistent_values(L,Agent,Domain,View,Nogoods).

