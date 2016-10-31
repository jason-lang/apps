// Agent broker in project infinite1.mas2j

/* Initial beliefs and rules */

initial_offer(c, orange, 10). // To make 4 cycles in offers and counter-offers
acceptable_offer(c, orange, 6).

/* Initial goals */

/* Plans */

+item(Client, Item)[source(s)] : initial_offer(Client, Item, Offer) 
   <- +current_offer(Client, Item, Offer); 
      !my_send(Client, tell, offer(Item, Offer)).

+counter(Item, Offer)[source(Client)] : acceptable_offer(Client, Item, Min) 
      & current_offer(Client, Item, Current) & Offer < Min & Offer > Min-4 
   <- !decrease(Client, Item, NewOffer); 
      !my_send(Client, tell, offer(Item, NewOffer)).

+counter(Item, Offer)[source(Client)] : acceptable_offer(Client, Item, Min) 
      & current_offer(Client, Item, Current) & Offer <= Min-4  
   <- !my_send(Client, tell, result(noDeal, Item, Offer)); 
      !my_send(s, tell, final(noDeal, Client, Item, Offer)).

+counter(Item, Offer)[source(Client)] : acceptable_offer(Client, Item, Min) 
      & Offer>=Min 
   <- !my_send(Client, tell, result(ok, Item, Offer)); 
      !my_send(s, tell, final(ok, Client, Item, Offer)).

+!decrease(Client, Item, NewOffer) : current_offer(Client, Item, Current) 
      & NewOffer = Current-1 
   <- -current_offer(Client, Item, Current); 
      +current_offer(Client, Item, NewOffer).


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
