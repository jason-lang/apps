package ia;

import graphLib.GlobalGraph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class setAgentPosition extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        GlobalGraph graph = GlobalGraph.getInstance();
        
        int id = (int) ((NumberTerm) args[0]).solve();
        String vertex = ((Atom) args[1]).getFunctor();
        
        graph.setPosition(id, vertex);
        
        return true;
    }
}
