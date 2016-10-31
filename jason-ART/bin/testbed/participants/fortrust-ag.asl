// Agent that uses the ForTrust model to decide
//

{ include("fortrust-model.asl") }

   
/* Some beliefs that are included by the Wrapper:

   eras(<list of the name of eras>)
   agents(<list of the name of agents>)
   opinion_cost(<value>)
   max_opinion_requests(<value>)
   
   opinion(<agent>, <era>, <painting>, <given value>, <real value>)
   
   my_expertise(<era>, <value>)
   painting(<era>, <id>, <appraisal object>)

*/


+!start_step
  <- !check_does;
     !assign_evaluators.
  

// Assign N partners for each painting (N is the max number of opinions)
+!assign_evaluators
   : max_opinion_requests(MReq)
  <- .abolish(partner(_,_));
     for (painting(Era,Painting,_) & .range(NC,1,MReq)) {
        !find_candidate(Era, Painting)
     }. 

/* 
 * --- --- --- --- --- --- --- --- --- 
 *         Reputation Protocol
 * --- --- --- --- --- --- --- --- --- 
 */

// define a function for reputation in an era (based on belief reputation/3)
{ register_function("reputation.ag.era",2,"reputation") } 


/* plan to handle prepareReputationRequests -- asks reputation of some agents */
+!prepareReputationRequests.      
      
/* plan to handle prepareReputationAcceptsAndDeclines -- accept or not reputation request */
+!prepareReputationAcceptsAndDecline(Requester, Target, Era, Transaction)
  <- // accept all requests
     .send(Requester, tell, reputation_accept(Transaction)); // or reputation_decline
     // store them for the next step
     +reputation_accept(Requester, Target, Era, Transaction).
 
/* plan to handle prepareReputationReplies -- answer reputation requests */
+!prepareReputationReplies
  <- // answer sincerely (based on power)
     for (reputation_accept(Requester, Target, Era, Transaction)) {
       .send(Requester,tell,reputation(Target, Era, reputation.ag.era(Target,Era), Transaction))
     };
     .abolish(reputation_accept(_, _, _, _)).

// answer for my requests of reputation will produce events like the following
/*
+recommendation(Target,Era,Value)[source(AgName)]
   : AgName \== self
  <- //.print("Received reputation for ",Target,"/",Era,"=",Value," from ",AgName);
     if (reputation(Target,Era,0.5)) {
        -reputation(Target,Era,_);
        +reputation(Target,Era,Value)
     }.
*/

/* 
 * --- --- --- --- --- --- --- --- --- 
 *         Certainty Protocol
 * --- --- --- --- --- --- --- --- --- 
 */

/* plan to handle prepareCertaintyRequests -- ask agents about their certainty in an era */
+!prepareCertaintyRequests
   : strategy(power,certainty) & eras(Eras) & agents(Ags) 
  <- // for each partner that certainty is old (or unknown), ask a newer value
     for (.member(Ag,Ags) & .member(Era,Eras)) { // we need these loops to avoid asking twice the same agent in the same era
        if (partner(Ag, Painting) & painting(Era,Painting,_) & is_old(certainty(Ag,Era,_))) {
           //.print("asked certainty for ",Ag," in era ",Era);
           .send(Ag, askOne, certainty(Era))
        }
     }.  
+!prepareCertaintyRequests.
     
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

/* plan to handle prepareOpinionRequests (triggered for each assignment) */
+!prepareOpinionRequest(E, Painting, Assignment)
  <- for (partner(Ag, Painting)) {
        //.print("Asking opinion for ", PaintId, " in era ",E," to ", Ag);
        .send(Ag, askOne, opinion(Assignment)) // send a message to him asking an opinion
     }.


/* plan to handle prepareOpinionCreationOrders */
// if requester is sincere, do my best for the requester -- spend 4 for the opinion
+!prepareOpinionCreationOrder(Requester, Era, Transaction, Assignment)
   : sincere(Requester)
  <- .send(sim, tell, opinion(Transaction, Assignment, 3)).
// otherwise, do not collaborate
+!prepareOpinionCreationOrder(Requester, Era, Transaction, Assignment)
  <- .send(sim, tell, opinion(Transaction, Assignment, 0.5)).


/* plan to handle prepareOpinionProviderWeights */
+!prepareOpinionProviderWeights
   : eras(Eras) & agents(Ags) 
  <- //.print("Sending providers weights to the simulator.");
     for (.member(A,Ags) & .member(E,Eras)) {
        ?ag_weight(A,E,Value);
        .send(sim,tell, weight_msg(A,E,Value))
     }.
     

/* general plans and rules */

random_ag(Ag) :- 
   agents(LAgs) &                               // get the list of agents
   .nth(math.random(.length(LAgs)), LAgs, Ag).  // choose a random agent

is_old(P) :- (not P | (step(Current) & P[step(N)] & Current - N > 7)).
