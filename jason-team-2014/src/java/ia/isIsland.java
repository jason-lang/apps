package ia;

import graphLib.GlobalGraph;
import graphLib.Graph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class isIsland extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        GlobalGraph globalGraph = GlobalGraph.getInstance();
        Graph graph = globalGraph.getGraph();
        
        String vertexV = ((Atom) args[0]).getFunctor();
        
        return globalGraph.getIsland(graph.vertex2Integer(vertexV)) != null;
    }
}
