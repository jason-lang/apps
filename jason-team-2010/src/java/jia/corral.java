package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import arch.CowboyArch;
import env.WorldModel;

/** test if some location is inside corral */
public class corral extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        WorldModel model = ((CowboyArch)ts.getUserAgArch()).getModel();
        int x = (int)((NumberTerm)terms[0]).solve(); 
        int y = (int)((NumberTerm)terms[1]).solve();
        return model.hasObject(WorldModel.CORRAL, x, y); 
    }
}

