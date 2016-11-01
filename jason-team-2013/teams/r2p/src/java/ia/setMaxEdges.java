package ia;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class setMaxEdges extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
    	
		graph.setMaxEdges((int) ((NumberTerm) terms[0]).solve());
    	
        return true;
    }
}
