package mds;

import jason.asSemantics.*;
import jason.asSyntax.*;

public class calculateMyBid implements InternalAction {
    
    public boolean execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        String id = ts.getAgArch().getAgName().substring(3);
        int bid = Integer.parseInt(id) * 10;
        // args[0] is the unattended luggage Report Number
        return un.unifies(args[1], Term.parse(""+bid));
        //System.out.println("**="+un);
    }
}
