// Agent q4_4 in project queen_4.mas2j
{ include("abt.asl") }
{ include("queen_conflict.asl") }
/* Initial beliefs and rules */
agent_view([]).
nogood_list([]).
domain(q4_4,[[4,1],[4,2],[4,3],[4,4]]).
links(q4_4,[]).
current_value([4,1]).
/* Initial goals */
!start.
