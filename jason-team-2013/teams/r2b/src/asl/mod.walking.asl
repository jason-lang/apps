/* Plans to random walk */
+!random_walk: 
    is_good_destination(Op)
<- 
    .print("I have chose ",Op);
    !goto(Op).
    
+!random_walk: 
    true
<- 
    .print("I don't know where I'm going, so I'm going to recharge");
    !recharge.
    
/* Plans to walk in a path */    
+!gotoPath([]):
    true
<-
    .print("ERROR. I do not know any path and I'm lost.");
    !random_walk.
    
+!gotoPath([V|[]]):
    position(V)
<-
    .print("ERROR. I do not know any path and I'm lost two.");
    !random_walk.
    
+!gotoPath([V|T]):
    position(V)
<-
    !gotoPath(T).
    
+!gotoPath([V|_]):
    true
<-
    .print("My next step in the path is ", V);
    !goto(V).