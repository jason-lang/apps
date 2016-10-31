!start1.
!start2.

+!start1 : true 
   <- .print("init");
      .wait(2000); 
      .print("ERROR"); 
      !start1.

+!start2 : true 
   <- .wait(100); .drop_intention(start1); .print("removed"); .wait(5000); .stopMAS.

