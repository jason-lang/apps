package testbed.participants;

import static jason.asSyntax.ASSyntax.createLiteral;
import static jason.asSyntax.ASSyntax.createNumber;
import static jason.asSyntax.ASSyntax.createString;
import static jason.asSyntax.ASSyntax.createStructure;

import jason.RevisionFailedException;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Atom;
import jason.asSyntax.ListTerm;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.ObjectTerm;
import jason.asSyntax.ObjectTermImpl;
import jason.asSyntax.StringTerm;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;

import java.util.ArrayList;
import java.util.List;

import testbed.agent.Agent;
import testbed.messages.CertaintyReplyMsg;
import testbed.messages.CertaintyRequestMsg;
import testbed.messages.OpinionOrderMsg;
import testbed.messages.OpinionReplyMsg;
import testbed.messages.OpinionRequestMsg;
import testbed.messages.ReputationAcceptOrDeclineMsg;
import testbed.messages.ReputationReplyMsg;
import testbed.messages.ReputationRequestMsg;
import testbed.messages.WeightMsg;
import testbed.sim.Appraisal;
import testbed.sim.AppraisalAssignment;
import testbed.sim.Era;
import testbed.sim.Opinion;
import testbed.sim.Weight;

/**
 * This class implements an ART agent that delegates all tasks to a Jason Agent.
 * 
 * @author hubner
 */
@SuppressWarnings("unchecked")
public abstract class JasonARTWrapper extends Agent {

    JasonARTAgent             jason;
    List<OpinionRequestMsg>   opinionRequests;

	public void initializeAgent(String src, boolean dump) {
        try {
    	    jason = new JasonARTAgent(this, getName(), src);
    	    if (dump)
    	        jason.setDumpDirectory("status-"+getName());
    	    
    	    // add a list of eras as belief
    	    ListTerm le = ASSyntax.createList();
    	    ListTerm last = le.getLast();
    	    for (Era e: eras) {
    	        last = last.append(era2term(e));
    	    }
    	    Literal eras = createLiteral("eras", le);
            jason.getAg().addBel(eras);
            
            // add a list of agents as belief
            le = ASSyntax.createList();
            last = le.getLast();
            for (String name: agentNames) {
                if (!name.equals(getName()))
                    last = last.append(ag2term(name));
            }
            Literal agents = createLiteral("agents", le);
            jason.getAg().addBel(agents);

            Literal opcost = createLiteral("opinion_cost", createNumber(opinionCost));
            jason.getAg().addBel(opcost);
            
            Literal maxReq = createLiteral("max_opinion_requests", createNumber(maxNbOpinionRequests));
            jason.getAg().addBel(maxReq);

            // other initial information should be send in the same way
            // max nb of opinions, ....
            
        } catch (Exception e) {
            System.err.println("Error initialising JasonARTWrapper: "+e);
            e.printStackTrace();
        }
	}

    /* 
     * --- --- --- --- --- --- --- --- --- 
     *         Reputation Protocol
     * --- --- --- --- --- --- --- --- --- 
     */
	
	@Override
	public void prepareReputationRequests() {
	    // do not ask reputation

	    // add results of the last cycle as perception for the agent
	    List<Literal> percepts = new ArrayList<Literal>();

	    Literal pstep = createLiteral("step", createNumber(currentTimestep));
	    percepts.add(pstep);
	    jason.getUserAgArch().setCycleNumber(currentTimestep);
	    
        // First collect the replies to the previous opinion transactions
        if (finalAppraisals != null) {
            List<OpinionReplyMsg> opinionReplies = getIncomingMessages();
        	for (Appraisal appraisal: finalAppraisals) {
        		for (OpinionReplyMsg msg: opinionReplies) {
        		    if (msg.getAppraisalAssignment().getPaintingID().equals(appraisal.getPaintingID())) {
        			    
        		        // build percept like opinion(timestep, agent, era, given value, real value);
        			    Literal p = createLiteral("opinion",
        			            ag2term(msg.getOpinion().getOpinionProvider()),
        			            era2term(msg.getAppraisalAssignment().getEra()),
        			            createString(msg.getAppraisalAssignment().getPaintingID()),
        			            createNumber(msg.getOpinion().getAppraisedValue()),
        			            createNumber(appraisal.getTrueValue()));
                        percepts.add(p);
        			}
        		}
        	}
        }
        
        // include the expertise in the percepts
        for (Era e: eras) {
            double myExpertise = 1 - myExpertiseValues.get(e.getName());
            percepts.add(createLiteral("my_expertise", era2term(e), createNumber(myExpertise)));
        }
        
        // include paintings
        for (AppraisalAssignment assignment: assignedPaintings) {
            Literal p = createLiteral("painting", 
                    era2term(assignment.getEra()), 
                    createString(assignment.getPaintingID()),
                    new ObjectTermImpl(assignment));
            percepts.add(p);
        }        
        
        jason.setPercepts(percepts);
        jason.getTS().getC().addAchvGoal(createLiteral("start_step"), null);
        jason.run(); // run the Jason agent to achieve the goals
        
        jason.dumpMind(); // store a copy of the mind of the agent for debugging
                          // COMMENT it to save execution time
        
        jason.getTS().getC().addAchvGoal(createLiteral("prepareReputationRequests"), null);
        jason.run(); // run the Jason agent to achieve the goals        
	}

	@Override
	public void prepareReputationAcceptsAndDeclines() {
        // Get reputation request messages from the message inbox
        List<ReputationRequestMsg> reputationRequests = getIncomingMessages();
        
        for (ReputationRequestMsg msg: reputationRequests) {
            // create goals
            Literal goal = createLiteral("prepareReputationAcceptsAndDecline",
                    ag2term(msg.getSender()),
                    ag2term(msg.getAppraiserID()),
                    era2term(msg.getEra()),
                    transaction2term(msg.getAppraiserID()));
            jason.getTS().getC().addAchvGoal(goal, null);
        }
        
        jason.run();
	}

	@Override
	public void prepareReputationReplies() {
        // first collect the reputation accept or decline messages
        @SuppressWarnings("unused")
        List<ReputationAcceptOrDeclineMsg> reputationAcceptsAndDeclines = getIncomingMessages();
        
        jason.getTS().getC().addAchvGoal(createLiteral("prepareReputationReplies"), null);
        jason.run();
	}
	
	/* 
     * --- --- --- --- --- --- --- --- --- 
     *         Certainty Protocol
     * --- --- --- --- --- --- --- --- --- 
     */
   
    @Override
	public void prepareCertaintyRequests() {
        List<ReputationReplyMsg> reputationReplies = getIncomingMessages();
        // add the answers as beliefs
        for (ReputationReplyMsg msg: reputationReplies) {
            Literal r = createLiteral("recommendation",
                    ag2term(msg.getAppraiserID()),
                    era2term(msg.getEra()),
                    createNumber(msg.getReputation()));
            r.addSource(ag2term(msg.getSender()));
            r.addAnnot(createStructure("step", createNumber(this.currentTimestep)));
            try {
                jason.getAg().addBel(r);
            } catch (RevisionFailedException e) {
                e.printStackTrace();
            }
            //jason.getTS().getC().addEvent(new Event(new Trigger(Trigger.TEOperator.add, Trigger.TEType.belief, r), null));
        }
        
        jason.getTS().getC().addAchvGoal(createLiteral("prepareCertaintyRequests"), null);
        jason.run();        
	}

	@Override
	public void prepareCertaintyReplies() {
        List<CertaintyRequestMsg> certRequests = getIncomingMessages();
        
        for (CertaintyRequestMsg msg: certRequests) {
            Literal goal = createLiteral("prepareCertaintyReply",
                    ag2term(msg.getSender()),
                    era2term(msg.getEra()), // add the era in the goal
                    transaction2term(msg.getTransactionID()));
            jason.getTS().getC().addAchvGoal(goal, null);
        }
        
        jason.run();
	}

	
    /* 
     * --- --- --- --- --- --- --- --- --- 
     *         Opinion Protocol
     * --- --- --- --- --- --- --- --- --- 
     */
    
	@Override
    public void prepareOpinionRequests() {
        List<CertaintyReplyMsg> opinionCertainties = getIncomingMessages();
        for (CertaintyReplyMsg msg: opinionCertainties) {
            Literal r = createLiteral("certainty", 
                    ag2term(msg.getSender()),
                    era2term(msg.getEra()),
                    createNumber(msg.getCertainty()));
            r.addAnnot(createStructure(TimedBB.timeAnnotFunctor, createNumber(this.currentTimestep)));
            r.addSource(ag2term(msg.getSender()));
            try {
                jason.getAg().addBel(r);
            } catch (RevisionFailedException e) {
                e.printStackTrace();
            }
        }
        jason.run(); // run the Jason agent to achieve the goals

        // add one achievement goal for each appraisal
        for (AppraisalAssignment assignment: assignedPaintings) {
            Literal goal = createLiteral("prepareOpinionRequest",
                    era2term(assignment.getEra()), // add the era in the goal
                    createString(assignment.getPaintingID()),
                    new ObjectTermImpl(assignment)); // add the assignment object (used to sent the response)
            jason.getTS().getC().addAchvGoal(goal, null);
        }                
        jason.run(); // run the Jason agent to achieve the goals
    }        

	@Override
    public void prepareOpinionCreationOrders() {
        opinionRequests = getIncomingMessages();
        
        for (OpinionRequestMsg msg: opinionRequests) {
            Literal goal = createLiteral("prepareOpinionCreationOrder");
            goal.addTerm(ag2term(msg.getSender()));
            goal.addTerm(era2term(msg.getAppraisalAssignment().getEra())); // add the era in the goal
            goal.addTerm(transaction2term(msg.getTransactionID()));
            goal.addTerm(new ObjectTermImpl(msg.getAppraisalAssignment())); // add the assignment object (used to sent the response)
            jason.getTS().getC().addAchvGoal(goal, null);
            
        }
        jason.run(); // run the Jason agent to achieve the goals
    }

	@Override
	public void prepareOpinionProviderWeights() {
        jason.getTS().getC().addAchvGoal(createLiteral("prepareOpinionProviderWeights"), null);
	    jason.run();
	}

    @Override
    public void prepareOpinionReplies() {
        for (OpinionRequestMsg receivedMsg: opinionRequests) {
            Opinion op = findOpinion(receivedMsg.getTransactionID());
            if (op != null) {
                OpinionReplyMsg msg = receivedMsg.opinionReply(op);
                sendOutgoingMessage(msg);
            }
        }
    }

    private Opinion findOpinion(String _transactionID) {
        for (Opinion op: createdOpinions) {
            if (op.getTransactionID().equals(_transactionID)) {
                return op;
            }
        }
        return null;
    }

    
	/** sends jason messages to ART simulator */
	public void sendJasonMsg(jason.asSemantics.Message m) {
	    Structure content = (Structure)m.getPropCont();
	    if (m.isAsk() && content.getFunctor().equals("opinion")) {
	        // opinion request message (fist arq of content is the assignment) 
	        AppraisalAssignment aa = (AppraisalAssignment)((ObjectTerm)content.getTerm(0)).getObject();
	        sendOutgoingMessage(new OpinionRequestMsg(m.getReceiver(),null,aa));
	    } else if (m.isTell() && content.getFunctor().equals("opinion")) {
            String transaction     = ((StringTerm)content.getTerm(0)).getString();
            AppraisalAssignment aa = (AppraisalAssignment)((ObjectTerm)content.getTerm(1)).getObject();
            double value           = ((NumberTerm)content.getTerm(2)).solve();
            sendOutgoingMessage(new OpinionOrderMsg(transaction, aa, value));
            //System.out.println("**** op for "+aa.getAppraiser());
	        
	    } else if (content.getFunctor().equals("weight_msg")) {
	        // weight message (args= agent, era, value)
	        String ag  = ((StringTerm)content.getTerm(0)).getString();
	        String era = content.getTerm(1).toString();
	        double wt  = ((NumberTerm)content.getTerm(2)).solve();
	        //System.out.println("Weight "+ag+" for "+era+" = "+wt);
            WeightMsg msg = new WeightMsg(new Weight(getName(), ag, wt, era));
            sendOutgoingMessage(msg);
            
        } else if (m.isAsk() && content.getFunctor().equals("reputation")) {
            String ag  = ((StringTerm)content.getTerm(0)).getString();
            String era = content.getTerm(1).toString();
            ReputationRequestMsg msg = new ReputationRequestMsg(m.getReceiver(), null, str2era(era), ag);
            sendOutgoingMessage(msg);

        } else if (m.isTell() && content.getFunctor().equals("reputation")) {
            String ag  = ((StringTerm)content.getTerm(0)).getString();
            String era = content.getTerm(1).toString();
            double rep = ((NumberTerm)content.getTerm(2)).solve();
            String transaction  = ((StringTerm)content.getTerm(3)).getString();
            //System.out.println("* send rep to "+m.getReceiver()+" about "+ag+"/"+era+" = "+rep);
            ReputationReplyMsg msg = new ReputationReplyMsg(m.getReceiver(), transaction, str2era(era), ag, rep);
            sendOutgoingMessage(msg);

        } else if (content.getFunctor().equals("reputation_accept")) {
            String transaction  = ((StringTerm)content.getTerm(0)).getString();
            //System.out.println("** accept " + transaction + " for " + m.getReceiver());
            sendOutgoingMessage(new ReputationAcceptOrDeclineMsg( m.getReceiver(), transaction, true));

        } else if (content.getFunctor().equals("reputation_decline")) {
            String transaction  = ((StringTerm)content.getTerm(0)).getString();
            sendOutgoingMessage(new ReputationAcceptOrDeclineMsg( m.getReceiver(), transaction, false));

        } else if (m.isAsk() && content.getFunctor().equals("certainty")) {
            String era = content.getTerm(0).toString();
            sendOutgoingMessage(new CertaintyRequestMsg(m.getReceiver(),null, str2era(era)));
            
        } else if (m.isTell() && content.getFunctor().equals("certainty")) {
            String era = content.getTerm(0).toString();
            double exp = ((NumberTerm)content.getTerm(1)).solve();
            String transaction  = ((StringTerm)content.getTerm(2)).getString();
            sendOutgoingMessage(new CertaintyReplyMsg(m.getReceiver(), transaction, str2era(era), exp));
            
	    } else {
	        System.err.println("Unknown message type "+m);
	    }
	}

	
	
	Era str2era(String era) {
	    for (Era e: eras) 
	        if (e.getName().equals(era))
	            return e;
	    System.err.println("Unknown era "+era);
	    return null;
	}
	
	Term era2term(Era e) {
	    return new Atom(e.getName());
	}
	
	Term ag2term(String ag) {
	    return createString(ag);
	}
	
	Term transaction2term(String tID) {
	    return createString(tID);
	}
}
