+!loadAgentNames: 
    true
<-
   +friend(explorer1, b1, explorer);
   +friend(explorer2, b2, explorer);
   +friend(repairer1, b3, repairer);
   +friend(repairer2, b4, repairer);
   +friend(saboteur1, b5, saboteur);
   +friend(saboteur2, b6, saboteur);
   +friend(sentinel1, b7, sentinel);
   +friend(sentinel2, b8, sentinel);
   +friend(inspector1, b9, inspector);
   +friend(inspector2, b10, inspector);
   +friend(explorer3, b11, explorer);
   +friend(explorer4, b12, explorer);
   +friend(repairer3, b13, repairer);
   +friend(repairer4, b14, repairer);
   +friend(saboteur3, b15, saboteur);
   +friend(saboteur4, b16, saboteur);
   +friend(sentinel3, b17, sentinel);
   +friend(sentinel4, b18, sentinel);
   +friend(inspector3, b19, inspector);
   +friend(inspector4, b20, inspector);
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
