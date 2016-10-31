package jia;

import java.util.logging.Level;

import env.WorldModel;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import arch.MinerArch;

public class obstacle extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
    	try {
	        WorldModel model = ((MinerArch)ts.getUserAgArch()).getModel();
	        NumberTerm x = (NumberTerm)terms[0]; 
	        NumberTerm y = (NumberTerm)terms[1];
	        return model.hasObject(WorldModel.OBSTACLE, (int)x.solve(), (int)y.solve());
		} catch (Throwable e) {
	        ts.getLogger().log(Level.SEVERE, "jia.obstacle error: "+e, e);    		
		}
		return false;
    }
}

