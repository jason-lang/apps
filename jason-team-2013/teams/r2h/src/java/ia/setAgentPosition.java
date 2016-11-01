// Internal action code for project smadasMAPC2012

package ia;

import env.MixedAgentArch;
import graphLib.GlobalGraph;
import graphLib.Graph;
import jason.*;
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
