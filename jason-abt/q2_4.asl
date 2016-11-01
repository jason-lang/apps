// Agent q2_4 in project queen_4.mas2j
{ include("abt.asl") }
{ include("queen_conflict.asl") }
/* Initial beliefs and rules */
agent_view([]).
nogood_list([]).
domain(q2_4,[[2,1],[2,2],[2,3],[2,4]]).
links(q2_4,[q3_4,q4_4]).
current_value([2,1]).
/* Initial goals */
!start.
