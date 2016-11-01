package ia;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class setVertexVisited extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
    	
		String vertexV = ((Atom) terms[0]).getFunctor();
		int step = (int) ((NumberTerm) terms[1]).solve();
		
		graph.setVertexVisited(vertexV, step);
    	
        return true;
    }
}
