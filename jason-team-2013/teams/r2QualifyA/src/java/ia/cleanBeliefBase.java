package ia;

import java.util.Iterator;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;

public class cleanBeliefBase extends DefaultInternalAction {
    @Override public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        Iterator<Literal> il = ts.getAg().getBB().iterator();
        while (il.hasNext()) {
            Literal inBB = il.next();
            if (!inBB.isRule()) {
            	ts.getAg().getBB().remove(inBB);
            }
        }
        
        return true;
    }
    
}
