package ia;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class getDistance extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        
		String vertexS = ((Atom) terms[0]).getFunctor();
		String vertexD = ((Atom) terms[1]).getFunctor();
		VarTerm lenght = ((VarTerm) terms[2]);
		
    	un.unifiesNoUndo(lenght, new NumberTermImpl(graph.getDistance(vertexS, vertexD)));
    	
    	return true;
    }
}
