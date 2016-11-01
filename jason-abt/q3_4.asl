// Agent q3_4 in project queen_4.mas2j
{ include("abt.asl") }
{ include("queen_conflict.asl") }
/* Initial beliefs and rules */
agent_view([]).
nogood_list([]).
domain(q3_4,[[3,1],[3,2],[3,3],[3,4]]).
links(q3_4,[q4_4]).
current_value([3,1]).
/* Initial goals */
!start.
