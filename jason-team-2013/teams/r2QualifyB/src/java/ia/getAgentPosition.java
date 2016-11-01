package ia;

import graphLib.GlobalGraph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class getAgentPosition extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        GlobalGraph graph = GlobalGraph.getInstance();
        
        int id = (int) ((NumberTerm) args[0]).solve();
        
        String vertex = graph.getPosition(id);
        
        if (vertex == null) {
        	return false;
        } else {
        	Term vertexTerm = new Atom(vertex);
        	return un.unifiesNoUndo(args[1], vertexTerm);
        }
    }
}
