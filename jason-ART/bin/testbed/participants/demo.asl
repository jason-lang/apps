// Agent demo in project JasonART
//
// based on the agent SimpleAgent.java that comes with ART examples
//


   
/* Some beliefs that are included by the Wrapper:

   eras(<list of the name of eras>)
   agents(<list of the name of agents>)
   opinion_cost(<value>)
   max_opinion_requests(<value>)

   opinion(<agent>, <era>, <painting>, <given value>, <real value>)

   step(<value>)
   my_expertise(<era>, <value>)
   painting(<era>, <id>, <appraisal object>)

*/

//+eras(E)   <- .print("Eras are ",E).
//+agents(L) <- .print("Agents are ",L). 
              

+!start_step <- !init_reputation.

 
/* useful plans and rules for reputation belief */

// there are belief in the form reputation(agent,era,value)
// that are managed by the agent
+!init_reputation
   : eras(Eras) & agents(Ags) 
  <- .abolish(reputaton(_,_,_));
     for (.member(A,Ags)) {
       for (.member(E,Eras)) {
         +reputation(A,E,0.5) // initial evaluation of the agents
       }
     }.

// my own reputation is my expertise
reputation(Me,Era,Rep) :- .my_name(Name) & .term2string(Name,Me) & my_expertise(Era, Rep).

// overall reputation of an agent is the mean reputation in the areas
reputation(A,R) :-
   .findall(V,reputation(A,_,V),LV) &
   R = math.average(LV). // & .print("mean rep of ",A," is ",R," based on ",LV).   
// define a function for above rule
{ register_function("reputation.ag",1,"reputation") } 

// define a function for reputation in an era (based on belief reputation/3)
{ register_function("reputation.ag.era",2,"reputation") } 


/* 
 * --- --- --- --- --- --- --- --- --- 
 *         Reputation Protocol
 * --- --- --- --- --- --- --- --- --- 
 */
 
/* plan to handle prepareReputationRequests -- asks reputation of some agents */
+!prepareReputationRequests
   : eras(Eras) & agents(Ags) 
  <- // ask reputation for all agents/eras I have doubt (reputation == 0.5)
     for (.member(A,Ags)) {
       for (.member(E,Eras)) {
         if (reputation(A,E,0.5)) {
            // ask only to nice agents
            for (.member(RepProvider,Ags)) { 
              if (RepProvider \== A & reputation.ag(RepProvider) > 0.5) { // TODO: sincerity should be used instead of reputation
                //.print("Asking reputation of ",A," in ",E," for ",RepProvider);
                .send(RepProvider, askOne, reputation(A,E))
              }
            }
         }
       }
     }.
      
 
/* plan to handle prepareReputationAcceptsAndDeclines -- accept or not reputation request */
+!prepareReputationAcceptsAndDecline(Requester, Target, Era, Transaction)
  <- // accept all requests
     .send(Requester, tell, reputation_accept(Transaction)); // or reputation_decline
     // store them for the next step
     +reputation_accept(Requester, Target, Era, Transaction).
 
/* plan to handle prepareReputationReplies -- answer reputation requests */
+!prepareReputationReplies
  <- // answer sincerely 
     for (reputation_accept(Requester, Target, Era, Transaction)) {
       .send(Requester,tell,reputation(Target, Era, reputation.ag.era(Target,Era), Transaction))
     };
     .abolish(reputation_accept(_, _, _, _)).

// answer for my requests of reputation will produce events like the following
+recommendation(Target,Era,Value)[source(AgName)]
   : AgName \== self
  <- //.print("Received reputation for ",Target,"/",Era,"=",Value," from ",AgName);
     if (reputation(Target,Era,0.5)) {
        -reputation(Target,Era,_);
        +reputation(Target,Era,Value)
     }.


/* 
 * --- --- --- --- --- --- --- --- --- 
 *         Certainty Protocol
 * --- --- --- --- --- --- --- --- --- 
 */

random_ag(Ag) :- 
   agents(LAgs) &                               // get the list of agents
   .nth(math.random(.length(LAgs)), LAgs, Ag).  // choose a random agent

/* plan to handle prepareCertaintyRequests -- ask agents about their certainty in an era */
+!prepareCertaintyRequests
  <- // just for example, request certanty to a random ag for each painting
     for (painting(Era,_,_)) {
        ?random_ag(Provider);
        .send(Provider, askOne, certainty(Era))
        //.print("asked certainty for ",Provider," in era ",Era)
     }.  
     
/* plan to handle prepareCertaintyReplies -- answer requested to my  own certainty */
+!prepareCertaintyReply(Requester, Era, Transaction)
   : my_expertise(Era,Exp)
  <- .send(Requester, tell, certainty(Era, Exp, Transaction)).

// the answers of certainty request are new beliefs in the form
// certainty(<ag>, <era>, <value>)[step(N)] 


/* 
 * --- --- --- --- --- --- --- --- --- 
 *         Opinion Protocol
 * --- --- --- --- --- --- --- --- --- 
 */
    
best_ag(Era,Ag) :-
   .my_name(Me) & .term2string(Me,MeS) &
   .findall(candidate(Rep,A), reputation(A,Era,Rep) & A \== MeS, LC) & // list of candidates
   .max(LC,candidate(_,Ag)). // & .print("Best candidate for ",Era," is ",Ag," based on ",LC).

/* plan to handle prepareOpinionRequests (triggered for each assignment) */
+!prepareOpinionRequest(E, PaintId, Assignment)
   : best_ag(E,Ag)                           // ask to the agent with best reputation
  <- //.print("Asking opion in era ",E," to ", Ag);
     .send(Ag, askOne, opinion(Assignment)). // send a message to him asking an opinion

/* plan to handle prepareOpinionCreationOrders */
+!prepareOpinionCreationOrder(Requester, Era, Transaction, Assignment)
  <- // do my best for the requester -- spend 10 for the opinion
     .send(sim, tell, opinion(Transaction, Assignment, 4)).

/* plan to handle prepareOpinionProviderWeights */
+!prepareOpinionProviderWeights
   : eras(Eras) & agents(Ags) 
  <- //.print("Sending providers weights to the simulator.");
     for (.member(A,Ags)) {
       for (.member(E,Eras)) {
         .send(sim,tell, weight_msg(A,E,reputation.ag.era(A,E))) // use reputation to weight the agents
       }
     }.
     
/* plan to handle received opinions */
@lo[atomic]
+opinion(Provider, Era, Painting, GivenValue, RealValue)
  <- D = math.abs(RealValue - GivenValue) / RealValue;
     ?reputation(Provider, Era, Rep);
     if (D > 0.5) { 
        NewRep = math.max(Rep - 0.2, 0)
     } {
        NewRep = math.min(Rep + 0.1, 1)
     };	
     //.print("new reputation of ",Provider," in ",Era," is ",NewRep);
     -reputation(Provider,Era,_);       // update the reputation of the agent
     +reputation(Provider,Era,NewRep). 
  