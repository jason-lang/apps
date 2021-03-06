package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;

import java.util.logging.Level;

import arch.CowboyArch;
import env.WorldModel;

/** test if some location is not in the grid OR has obstacle OR is CORRAL */
public class obstacle extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        try {
            WorldModel model = ((CowboyArch)ts.getUserAgArch()).getModel();
            int x = (int)((NumberTerm)terms[0]).solve(); 
            int y = (int)((NumberTerm)terms[1]).solve();
            return !model.inGrid(x,y) || model.hasObject(WorldModel.OBSTACLE, x, y) || model.hasObject(WorldModel.CORRAL, x, y);
        } catch (Throwable e) {
            ts.getLogger().log(Level.SEVERE, "jia.obstacle error: "+e, e);          
        }
        return false;
    }
}

