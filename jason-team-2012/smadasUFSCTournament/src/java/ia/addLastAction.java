// Internal action code for project smadasMAPC2012

package ia;

import env.ContestLogger;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class addLastAction extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {

        String team = unQuote(args[0].toString());
        int agentId = (int) ((NumberTerm) args[1]).solve();
        int step = (int) ((NumberTerm) args[2]).solve();
        String action = ((Atom) args[3]).getFunctor();
        String result = ((Atom) args[4]).getFunctor();
        
        ContestLogger.getInstance().addAction(team, agentId, step, action, result);
        
        return true;
    }
    
    private String unQuote(String str) {
        if (str.charAt(0) == '"' && str.charAt(str.length()-1) == '"' )
            return str.substring(1, str.length()-1);
        return str;
    }
}
