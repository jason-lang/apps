+!loadAgentNames: 
    true
<-
   +friend(explorer1, a1, explorer);
   +friend(explorer2, a2, explorer);
   +friend(repairer1, a3, repairer);
   +friend(repairer2, a4, repairer);
   +friend(saboteur1, a5, saboteur);
   +friend(saboteur2, a6, saboteur);
   +friend(sentinel1, a7, sentinel);
   +friend(sentinel2, a8, sentinel);
   +friend(inspector1, a9, inspector);
   +friend(inspector2, a10, inspector);
   +friend(explorer3, a11, explorer);
   +friend(explorer4, a12, explorer);
   +friend(repairer3, a13, repairer);
   +friend(repairer4, a14, repairer);
   +friend(saboteur3, a15, saboteur);
   +friend(saboteur4, a16, saboteur);
   +friend(sentinel3, a17, sentinel);
   +friend(sentinel4, a18, sentinel);
   +friend(inspector3, a19, inspector);
   +friend(inspector4, a20, inspector);
   +generalPriority(inspector1, 1);
   +generalPriority(inspector2, 2);
   +generalPriority(inspector3, 3);
   +generalPriority(inspector4, 4);
   +generalPriority(explorer1, 5);
   +generalPriority(explorer2, 6);
   +generalPriority(explorer3, 7);
   +generalPriority(explorer4, 8);
   +generalPriority(sentinel1, 9);
   +generalPriority(sentinel2, 10);
   +generalPriority(sentinel3, 11);
   +generalPriority(sentinel4, 12);
   +generalPriority(repairer1, 13);
   +generalPriority(repairer2, 14);
   +generalPriority(repairer3, 15);
   +generalPriority(repairer4, 16);
   +generalPriority(saboteur1, 17);
   +generalPriority(saboteur2, 18);
   +generalPriority(saboteur3, 19);
   +generalPriority(saboteur4, 20).

+!testAgentNames:
    .count((friend(_, _, _)), N) & N \== 20 |
    .count((generalPriority(_, _)), K) & K \== 20
<-
    .abolish(friend(_, _, _));
    .abolish(generalPriority(_, _));
    !loadAgentNames.
+!testAgentNames: true <- true. 
