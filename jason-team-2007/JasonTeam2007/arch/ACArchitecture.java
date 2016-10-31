package arch;

import jason.JasonException;
import jason.asSemantics.ActionExec;
import jason.asSyntax.Literal;
import jason.asSyntax.Structure;
import jason.mas2j.ClassParameters;
import jason.runtime.Settings;

import java.util.ArrayList;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.logging.Logger;

/** 
 * 
 * Jason agent architecture customisatioin 
 * (it links the agentspeak interpreter to the contest simulator)
 * 
 * @author Jomi
 *
 */
public class ACArchitecture extends MinerArch {

	private Logger logger;	

	private ACProxy       proxy;
	private List<Literal> perceptions = new ArrayList<Literal>();
	
	//ActionExec acExec; // action of the current cycle
	
	@Override
    public void initAg(String agClass, ClassParameters bbPars, String asSrc, Settings stts) throws JasonException {
		super.initAg(agClass, bbPars, asSrc, stts);
		logger = Logger.getLogger(ACArchitecture.class.getName()+"."+getAgName());

		String username = stts.getUserParameter("username");
        if (username.startsWith("\"")) username = username.substring(1,username.length()-1);
        String password = stts.getUserParameter("password");
        if (password.startsWith("\"")) password = password.substring(1,password.length()-1);
        
		proxy = new ACProxy( 	this, 
								stts.getUserParameter("host"), 
								Integer.parseInt(stts.getUserParameter("port")),
								username,
								password);
		proxy.start();
	}

	@Override
	public List<Literal> perceive() {
		return new ArrayList<Literal>(perceptions);
	}

	Queue<ActionExec> toExecute = new ConcurrentLinkedQueue<ActionExec>();
    
	public void startNextStep(int step, List<Literal> p) {
		perceptions = p;

		List<ActionExec> feedback = getTS().getC().getFeedbackActions();
		while (!toExecute.isEmpty()) {
    		ActionExec action = toExecute.poll();
    		action.setResult(true);
			feedback.add(action);
		}
		
		getTS().newMessageHasArrived();
    	setCycle(step);
	}
	
	@Override
	public void act(final ActionExec act, List<ActionExec> feedback) {
        final Structure acTerm = act.getActionTerm();
        if (acTerm.getFunctor().equals("do")){
        	// (to not block the TS)
        	new Thread() {
        		public void run() {
                    proxy.sendAction(acTerm.getTerm(0).toString());
                    toExecute.offer(act);
        		}
        	}.start();
        } else {
        	logger.info("ignoring action "+acTerm+", it is not a 'do'.");
        }
	}	
}
