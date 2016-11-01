package ia;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class addEdge extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
    	
		String vertexU = ((Atom) terms[0]).getFunctor();
		String vertexV = ((Atom) terms[1]).getFunctor();
		int weight = (int) ((NumberTerm) terms[2]).solve();
		
		graph.addEdge(vertexU, vertexV, weight);
		
        return true;
    }
}
