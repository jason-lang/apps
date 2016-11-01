// Internal action code for project smadasMAPC2012

package ia;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class setMaxVertices extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        
        graph.setMaxVertices((int) ((NumberTerm) terms[0]).solve());
        
        return true;
    }
}
