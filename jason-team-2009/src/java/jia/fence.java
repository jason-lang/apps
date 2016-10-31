package jia;

import env.WorldModel;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import arch.CowboyArch;
import arch.LocalWorldModel;

/** test if some location contains a fence */
public class fence extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        LocalWorldModel model = ((CowboyArch)ts.getUserAgArch()).getModel();
        int x = (int)((NumberTerm)terms[0]).solve(); 
        int y = (int)((NumberTerm)terms[1]).solve();
        return model.hasObject(WorldModel.FENCE, x, y);
    }
}

