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
	
	ActionExec acExec;
	
	public void initAg(String agClass, String asSrc, Settings stts) throws JasonException {
		super.initAg(agClass, asSrc, stts);
		logger = Logger.getLogger(ClimaArchitecture.class.getName()+"."+getAgName());
        String username = stts.getUserParameter("username");
        if (username.startsWith("\"")) username = username.substring(1,username.length()-1);
        String password = stts.getUserParameter("password");
        if (password.startsWith("\"")) password = password.substring(1,password.length()-1);
        boolean gui = true;
        if ("no".equals(stts.getUserParameter("gui"))) {
            gui = false;
        }
		clima = new ClimaProxy(this, 
				stts.getUserParameter("host"), 
				Integer.parseInt(stts.getUserParameter("port")),
				username,
				password,
                gui);
		//launch proxy agent
		try {
			// try to discover the ag id
			int id = Integer.parseInt(getAgName().substring(5));
			clima.setAgId(id-1);
		} catch (Exception e) {}
		clima.start();
	}

	public void addBel(Literal bel) {
		getTS().getAg().addBel(bel, BeliefBase.TSelf, getTS().getC(), Intention.EmptyInt);
	}
	
	public void remBel(Literal bel) {
		Unifier u = new Unifier();
		Literal bInBB = getTS().getAg().believes(bel,u);
        if (bInBB != null) {
        	getTS().getAg().delBel(bInBB, getTS().getC(), Intention.EmptyInt);
        } else {
        	logger.info("Can not remove "+bel+" since I don't believe in it!");
        }
	}

	public void doPerception(List p) {
		perceptions = p;
		getTS().newMessageHasArrived(); // it starts a reasoning cycle
		if (acExec != null) {
			getTS().getC().getFeedbackActions().add(acExec);
		}
	}
	
	public List perceive() {
		return perceptions;
	}

	public void act() {
		if (getTS().getC().getAction() == null) {
			return;
		}
		acExec = getTS().getC().getAction(); 
		Term acTerm = acExec.getActionTerm();
		logger.info("doing: "+acTerm);
		
		if (acTerm.getFunctor().equals("do")){
			clima.send(acTerm.getTerm(0).toString()); //, removeQuotes(acTerm.getTerm(1).toString()));
			acExec.setResult(true);
		}
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
