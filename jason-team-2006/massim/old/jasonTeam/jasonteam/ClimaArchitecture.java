package jasonteam;

import jason.JasonException;
import jason.architecture.AgArch;
import jason.asSemantics.ActionExec;
import jason.asSemantics.Intention;
import jason.asSemantics.Unifier;
import jason.asSyntax.BeliefBase;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import jason.runtime.Settings;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/** 
 * 
 * Jason agent architecture customisatioin 
 * (it links the agentspeak interpreter to the Clima simulator)
 * 
 * @author Jomi
 *
 */
public class ClimaArchitecture extends AgArch {

	private Logger logger;	

	ClimaProxy clima;
	List perceptions = new ArrayList();
	
	
	public void initAg(String agClass, String asSrc, Settings stts) throws JasonException {
		super.initAg(agClass, asSrc, stts);
		logger = Logger.getLogger(ClimaArchitecture.class.getName()+"."+getAgName());
		clima = new ClimaProxy(this, 
				    stts.getUserParameter("host"), 
					Integer.parseInt(stts.getUserParameter("port")),
					stts.getUserParameter("username"),
					stts.getUserParameter("password"));
		//launch proxy agent
		clima.start();
	}

	public void addBel(Literal bel) {
		getTS().getAg().addBel(bel, BeliefBase.TSelf, getTS().getC(), Intention.EmptyInt);
	}
	public void remBel(Literal bel) {
		Unifier u = new Unifier();
        if (getTS().getAg().believes(bel,u)) {
        	u.apply(bel);
        	getTS().getAg().delBel(bel, BeliefBase.TSelf, getTS().getC(), Intention.EmptyInt);
        } else {
        	logger.info("Can not remove "+bel+" since I don't believ in it!");
        }
	}

	public void doPerception(List p) {
		perceptions = p;
		getTS().newMessageHasArrived(); // it starts a reasoning cycle
	}
	
	public List perceive() {
		return perceptions;
	}

	public void act() {
    	ActionExec acExec = getTS().getC().getAction(); 
        if (acExec == null) {
            return;
        }
        Term acTerm = acExec.getActionTerm();
        logger.info("doing: "+acTerm);

        if (acTerm.getFunctor().equals("do")){
        	clima.send(acTerm.getTerm(0).toString()); //, removeQuotes(acTerm.getTerm(1).toString()));
            acExec.setResult(true);
        }
        getTS().getC().getFeedbackActions().add(acExec);
	}

	/*
	private String removeQuotes(String s) {
		return s.substring(1, s.length()-1);
	}
	*/
	
	public WorldModel getModel() {
		return clima.model;
	}
	
	// just for testing
	public static void main(String[] args) throws JasonException {
		ClimaArchitecture agent = new ClimaArchitecture();

		//configure network
		Settings stts = new Settings();
		stts.addOption("host", "localhost");
		stts.addOption("port", "12300");
		
		//configure credentials
		stts.addOption("username", "china1");
		stts.addOption("password", "1");
		
		agent.initAg(null, null, stts);
	}
}
