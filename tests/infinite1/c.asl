// Agent client in project infinite1.mas2j

/* Initial beliefs and rules */

// initial_counter_offer(b, orange, 2).
 initial_counter_offer(b, orange, 3).
// initial_counter_offer(b, orange, 4).
// initial_counter_offer(b, orange, 5).
// initial_counter_offer(b, orange, 6).

/* Initial goals */

/* Plans */

+offer(Item, Offer)[source(Buyer)] : initial_counter_offer(Buyer, Item, Initial) 
   <-  -initial_counter_offer(Buyer, Item, Initial); 
       -offer(Item, Offer)[source(Buyer)]; 
       +current_counter_offer(Buyer, Item, Initial); 
       !my_send(Buyer, tell, counter(Item, Initial)).

// Plan for session compliant behaviour
+offer(Item, Offer)[source(Buyer)] : true 
   <- -offer(Item, Offer)[source(Buyer)]; 
      !increase(Buyer, Item, NewOffer); 
      !my_send(Buyer, tell, counter(Item, NewOffer)).

// Plan for non session compliant behaviour
// +offer(Item, Offer)[source(Buyer)] : true 
//    <- -offer(Item, Offer)[source(Buyer)];  
//       !increase(Buyer, Item, NewOffer); 
//       !my_send(Buyer, tell, offer(Item, NewOffer)).

+result(Res, Item, Offer)[source(Buyer)]: true.

+!increase(Client, Item, NewOffer) : current_counter_offer(Client, Item, Current) 
       & NewOffer = Current+1 
   <- -current_counter_offer(Client, Item, Current); 
      +current_counter_offer(Client, Item, NewOffer).


/* Plans for runtime type checking */

+!my_send(Receiver, tell, Content) : true 
   <- .my_name(Sender);
      .send(monitor, tell, msg(Sender, Receiver, tell(Content))). 

+ok_check(msg(Sender, Receiver, tell(Content)))[source(monitor)] : true 
   <- -ok_check(msg(Sender, Receiver, tell(Content)))[source(monitor)]; 
      .send(Receiver, tell, Content).

+fail_check(msg(Sender, Receiver, tell(Content)))[source(monitor)] : true 
   <- .print("The following message I would have sent is not compliant with the session type: ", msg(Sender, Receiver, tell(Content)), "\nI stop here.\n").

+protocol_failed(Name): true 
   <- .print("Protocol ", Name, " failed\n").

+protocol_succeeded(Name): true 
   <- .print("Protocol ", Name, " succeeded\n").
