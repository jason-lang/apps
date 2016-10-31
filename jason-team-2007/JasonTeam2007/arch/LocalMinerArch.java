package arch;

import jason.asSemantics.ActionExec;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.infra.centralised.CentralisedEnvironment;
import jason.infra.centralised.RunCentralisedMAS;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Queue;

import env.MiningEnvironment;

/** architecture for local simulator */
public class LocalMinerArch extends MinerArch {


	/** this version of perceive is used in local simulator. it get
        the perception and updates the world model. only relevant perceptions
        are leaved in the list of perception for the agent.
      */
	@Override
	public List<Literal> perceive() {
		List<Literal> per = super.perceive();
		if (per != null) {
			Iterator<Literal> ip = per.iterator();
			while (ip.hasNext()) {
				Literal p = ip.next();
				String  ps = p.toString();
				if (ps.startsWith("cell") && ps.endsWith("obstacle)") && model != null) {
                    int x = (int)((NumberTerm)p.getTerm(0)).solve();
					int y = (int)((NumberTerm)p.getTerm(1)).solve();
					obstaclePerceived(x, y, p);
					ip.remove(); // the agent does not perceive obstacles
	
				} else if (ps.startsWith("pos") && model != null) {
					// announce my pos to others
					int x = (int)((NumberTerm)p.getTerm(0)).solve();
					int y = (int)((NumberTerm)p.getTerm(1)).solve();
					locationPerceived(x, y);

				} else if (ps.startsWith("carrying_gold") && model != null) {
					// creates the model
					int n = (int)((NumberTerm)p.getTerm(0)).solve();
					carriedGoldsPerceived(n);

                //} else if (ps.startsWith("cell") && ps.endsWith("ally)")  && model != null) {
                    //int x = (int)((NumberTerm)p.getTerm(0)).solve();
					//int y = (int)((NumberTerm)p.getTerm(1)).solve();
					//allyPerceived(x, y);
                	//ip.remove(); // the agent does not perceive Others

                } else if (ps.startsWith("cell") && ps.endsWith("gold)")  && model != null) {
                    int x = (int)((NumberTerm)p.getTerm(0)).solve();
					int y = (int)((NumberTerm)p.getTerm(1)).solve();
					goldPerceived(x, y);

                } else if (ps.startsWith("cell") && ps.endsWith("enemy)") && model != null) {
                    int x = (int)((NumberTerm)p.getTerm(0)).solve();
					int y = (int)((NumberTerm)p.getTerm(1)).solve();
					enemyPerceived(x, y);
					//ip.remove(); // the agent does not perceive others
                    
				} else if (model == null && ps.startsWith("gsize")) {
					// creates the model
					int w = (int)((NumberTerm)p.getTerm(1)).solve();
					int h = (int)((NumberTerm)p.getTerm(2)).solve();
					setSimId(p.getTerm(0).toString());
                    gsizePerceived(w,h);
                    ip.remove();

				} else if (model != null && ps.startsWith("steps")) {
					// creates the model
					int s = (int)((NumberTerm)p.getTerm(1)).solve();
                    stepsPerceived(s);
                    ip.remove();
					
				} else if (ps.startsWith("depot")) {
					int x = (int)((NumberTerm)p.getTerm(1)).solve();
					int y = (int)((NumberTerm)p.getTerm(2)).solve();
                    depotPerceived(x, y);
                    ip.remove();
				}
			}
		}
		return per;
	}
	
   	boolean           waitingExecution = false;
	Queue<ActionExec> toExecute = new LinkedList<ActionExec>();
	
	// ask action in the environment, but do not block the agent waiting the action to finish its execution
    synchronized public void act(ActionExec action, List<ActionExec> feedback) {
    	if (isRunning()) {
	    	if (waitingExecution) {
	    		toExecute.add(action);
	    	} else {
		    	waitingExecution = true;
		    	//getTS().getAg().getLogger().info("doing: " + action.getActionTerm());
		    	CentralisedEnvironment jEnv = RunCentralisedMAS.getRunner().getEnvironmentInfraTier();
		    	if (jEnv != null) {
			    	MiningEnvironment env = (MiningEnvironment)jEnv.getUserEnvironment();
			    	env.addActionInSchedule(this, action);
		    	}
	    	}
    	}
    }
    
    synchronized public void actFinished(ActionExec action) {
    	List<ActionExec> feedback = getTS().getC().getFeedbackActions();
    	feedback.add(action);
    	waitingExecution = false;
    	
    	// if there is an action waiting for execution
    	if (!toExecute.isEmpty()) {
    		action = toExecute.poll();
        	// if the action is for an intention already dropped (it is not in PA anymore), ignore it
        	if (getTS().getC().getPendingActions().containsKey(action.getIntention().getId())) {
        		act(action, feedback);
        	}
    	}
    	getTS().newMessageHasArrived(); // in case the agent is sleeping...
    }

}
