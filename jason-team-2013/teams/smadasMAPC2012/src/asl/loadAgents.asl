+!loadAgentNames: 
    true
<-
   +friend(explorer1, a1, explorer);
   +friend(explorer2, a2, explorer);
   +friend(explorer3, a3, explorer);
   +friend(explorer4, a4, explorer);
   +friend(explorer5, a5, explorer);
   +friend(explorer6, a6, explorer);
   
   +friend(repairer1, a7, repairer);
   +friend(repairer2, a8, repairer);
   +friend(repairer3, a9, repairer);
   +friend(repairer4, a10, repairer);
   +friend(repairer5, a11, repairer);
   +friend(repairer6, a12, repairer);

   +friend(saboteur1, a13, saboteur);
   +friend(saboteur2, a14, saboteur);
   +friend(saboteur3, a15, saboteur);
   +friend(saboteur4, a16, saboteur);

   +friend(sentinel1, a17, sentinel);
   +friend(sentinel2, a18, sentinel);
   +friend(sentinel3, a19, sentinel);
   +friend(sentinel4, a20, sentinel);
   +friend(sentinel5, a21, sentinel);
   +friend(sentinel6, a22, sentinel);
   
   +friend(inspector1, a23, inspector);
   +friend(inspector2, a24, inspector);
   +friend(inspector3, a25, inspector);
   +friend(inspector4, a26, inspector);
   +friend(inspector5, a27, inspector);
   +friend(inspector6, a28, inspector);
   +generalPriority(inspector1, 1);
   +generalPriority(inspector2, 2);
   +generalPriority(inspector3, 3);
   +generalPriority(inspector4, 4);
   +generalPriority(inspector5, 5);
   +generalPriority(inspector6, 6);
   +generalPriority(explorer1, 7);
   +generalPriority(explorer2, 8);
   +generalPriority(explorer3, 9);
   +generalPriority(explorer4, 10);
   +generalPriority(explorer5, 11);
   +generalPriority(explorer6, 12);
   +generalPriority(sentinel1, 13);
   +generalPriority(sentinel2, 14);
   +generalPriority(sentinel3, 15);
   +generalPriority(sentinel4, 16);
   +generalPriority(sentinel5, 17);
   +generalPriority(sentinel6, 18);
   +generalPriority(repairer1, 19);
   +generalPriority(repairer2, 20);
   +generalPriority(repairer3, 21);
   +generalPriority(repairer4, 22);
   +generalPriority(repairer5, 23);
   +generalPriority(repairer6, 24);
   +generalPriority(saboteur1, 25);
   +generalPriority(saboteur2, 26);
   +generalPriority(saboteur3, 27);
   +generalPriority(saboteur4, 28).

+!testAgentNames:
    .count((friend(_, _, _)), N) & N \== 28 |
    .count((generalPriority(_, _)), K) & K \== 28
<-
    .abolish(friend(_, _, _));
    .abolish(generalPriority(_, _));
    !loadAgentNames.
+!testAgentNames: true <- true. 
