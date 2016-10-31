// ForTrust model
//

/* initial beliefs */

strategy(power,certainty).
strategy(power,image).

/* Trust definition */

trust(J,Action,Goal)[cert(C)] :-
   goal(Goal)[cert(GC)] &           // I have the goal 
   does(J,Action)[cert(CC)] &       // J is capable and intends to perform the action
   after(J,Action,Goal)[cert(PC)] & // J has the power to achieve my goal doing the action
   C = (GC+CC+PC)/3.

/* goal component */

// I have the goal to evaluate the painting if it was allocated to me
goal(evaluate(PaintId,Era))[cert(1)] :- painting(Era,PaintId,_).  

/* can component */

// backgrond information, every agent is capable to produce an opinion
// can(J,Ac)[cert(1)] :- true. 

/* power component */

//after(Ag, opinion(Era), _)[cert(1)] :- true.
after(Ag, opinion(Era), _)[cert(V)] :- // power based on image and sincerity 
   strategy(power, image)     & sincere(Ag) & image(Ag, Era, V)     &  V > 0.5.
after(Ag, opinion(Era), _)[cert(V)] :- // power based on certainty and sincerity 
   strategy(power, certainty) & sincere(Ag) & 
   (not strategy(power, image) | not image(Ag, Era, _)) & // used when no image is available (or not image strategy)
   certainty(Ag, Era, V) &  V > 0.7.

/* intends component */

//does(J,Action)[cert(1)] :- true.
does(J,Action)[cert(C)] :- 
   opinions_count(J,Asked,Provided) & Asked > 0 & 
   C = Provided/Asked & C > 0.9.

+!check_does
  <- for (partner(Ag,Painting)) {
        ?opinions_count(Ag,Asked,Provided);
        if (opinion(Ag, _, Painting, _, _)) {
           +opinions_count(Ag,Asked+1,Provided+1)
        }{
           +opinions_count(Ag,Asked+1,Provided)
        }
     }.
  
opinions_count(Ag,0,0) :- true. // default values

/* plans that links the model to the ART agent */

+!find_candidate(Era, Painting)  // use trust to find a partner
   : agents(Ags) &
     .findall(opt(C,Ag), 
              .member(Ag, Ags) & not partner(Ag, Painting) & 
              trust(Ag, opinion(Era), evaluate(Painting,Era))[cert(C)],
              LCandidates) & //.print("candidates: ",LCandidates) &
     LCandidates \== []
  <- // get a random agent from the list of candidates
     //.nth(math.random(.length(LCandidates)), LCandidates, opt(_,Ag));
     
     // get the best agent in the list
     .max(LCandidates,opt(C,Ag));
     //.print("trust based assignment: ",Ag," to ",Painting,", ",Era," C=",C);
     +partner(Ag, Painting).
+!find_candidate(Era, Painting) // randomly select a partner
   : random_ag(Ag) &
     not partner(Ag, Painting) &
     sincere(Ag)
  <- //.print("random assignment: ",Ag," to ",Painting,", ",Era);
     +partner(Ag, Painting).
+!find_candidate(_, _).


/* plans to handle received opinions */
@lo[atomic]
+opinion(Provider, Era, Painting, GivenValue, RealValue)
  <- D = math.abs(RealValue - GivenValue) / RealValue;
     if (D > 10) { // D > 10 means a huge error in the evaluation
        +~sincere(Provider)[error(Painting, GivenValue, RealValue, D)]
     };
     if (D < 0.4) {
        -~sincere(Provider)
     };
     NormD = 1-math.min(math.max(D,0),1);
     ?image(Provider, Era, ImgVl); // consult current image
     NewImg = (ImgVl + NormD)/2;
     //.print("new image of ",Provider," in ",Era," is ",NewImg);
     +image(Provider, Era, NewImg). // update image value

// default value for image
image(_, _, 0.5) :- true.

// sincerity rules and plans
sincere(Ag) :- not ~sincere(Ag). // unknown agents are assumed as sincere

// define reputation based on power (necessary for the reputation protocol)
// my own reputation is my expertise
reputation(Ag,Era,Rep) :- .my_name(Name) & .term2string(Name,Ag) & my_expertise(Era, Rep).
reputation(Ag,Era,1)   :- after(Ag,opinion(Era),_).
reputation(_,_,0)      :- true.

// agent weight (necessary for the opinion protocol)
ag_weight(Ag,Era,Value) :- .my_name(Name) & .term2string(Name,Ag) & my_expertise(Era, Value).
ag_weight(Ag,Era,Value) :- after(Ag,opinion(Era),_)[cert(Value)].
ag_weight(_,_,0)        :- true.
