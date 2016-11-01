// Agent q1_4 in project queen_4.mas2j
{ include("abt.asl") }
{ include("queen_conflict.asl") }
/* Initial beliefs and rules */
agent_view([]).
nogood_list([]).
domain(q1_4,[[1,1],[1,2],[1,3],[1,4]]).
links(q1_4,[q2_4,q3_4,q4_4]).
current_value([1,1]).
/* Initial goals */
!start.
