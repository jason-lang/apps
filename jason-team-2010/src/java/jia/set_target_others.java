package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.HashMap;
import java.util.logging.Level;

import arch.CowboyArch;
import env.WorldModel;

/**
 * Use: set_target_others(+Id,+X,+Y);
 * @author gustavo
 *
 */
public class set_target_others extends DefaultInternalAction {
    HashMap<Integer, Location> oldTargetHM = new HashMap<Integer, Location>(); 

	
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
    	try {
    		NumberTerm agId = (NumberTerm)terms[0]; 
    		Location oldTarget = oldTargetHM.get((int)agId.solve());
    	    CowboyArch  arch = (CowboyArch)ts.getUserAgArch();
	        WorldModel model = arch.getModel();
	        if (model == null) {
	            ts.getLogger().log(Level.SEVERE, "no model to get near_least_visited!");
	        } else {
	        	
	            if (oldTarget != null && model.inGrid(oldTarget)) {
	            	model.remove(WorldModel.TARGET_OTHERS, oldTarget);
	            	//if (arch.getACViewer() != null)
	            	//    arch.getACViewer().getModel().remove(WorldModel.TARGET, oldTarget);
	            }
	            NumberTerm x = (NumberTerm)terms[1]; 
	            NumberTerm y = (NumberTerm)terms[2];
	            Location t = new Location((int)x.solve(), (int)y.solve());
	            if (model.inGrid(t)) {
		            model.add(WorldModel.TARGET_OTHERS, t);
                    //if (arch.getACViewer() != null)
                    //    arch.getACViewer().getModel().add(WorldModel.TARGET, t);
		            oldTarget = t;
	            }
	        }
	        if(oldTarget != null){
	        	oldTargetHM.remove((int)agId.solve());
	        	oldTargetHM.put((int)agId.solve(), oldTarget);
	        }
	        
	        return true;
    	} catch (Throwable e) {
            ts.getLogger().log(Level.SEVERE, "jia.set_target_others error: "+e, e);
        }
        return false;        
    }
}
