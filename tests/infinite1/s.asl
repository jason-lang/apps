// Agent monitor in project infinite1.mas2j

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true  
   <- .send(monitor, tell, register(global_type(brokering), [s,b,c]));
      !my_send(b, tell, item(c, orange)).

+final(Res, Client, Item, Offer)[source(Broker)] : true 
   <- .print("Result of transaction between ", Broker, " and ", Client, " for ", Item,  ": ",
       Res, " for price ", Offer, "\n").


/* Plans for runtime type checking */

+!my_send(Receiver, tell, Content) : true 
   <- .my_name(Sender);
      .send(monitor, tell, msg(Sender, Receiver, tell(Content))). 

+ok_check(msg(Sender, Receiver, tell(Content)))[source(monitor)] : true 
   <- -ok_check(msg(Sender, Receiver, tell(Content)))[source(monitor)]; 
      .send(Receiver, tell, Content).

+fail_check(msg(Sender, Receiver, tell(Content)))[source(monitor)] : true 
   <- .print("The following message I would have sent is not compliant with the global type: ", msg(Sender, Receiver, tell(Content)), "\nI stop here.\n").

+protocol_failed(Name): true 
   <- .print("Protocol ", Name, " failed\n").

+protocol_succeeded(Name): true 
   <- .print("Protocol ", Name, " succeeded\n").
