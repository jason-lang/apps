// Internal action code for project smadasMAPC2012

package ia;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class visitedVertex extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        Term vertex = args[0];
        int result = graph.getVertexVisited(((Atom) vertex).getFunctor());
        if (result != Graph.NULL) {
            return un.unifiesNoUndo(args[1], new NumberTermImpl(result));
        }
        return false;
    }
}
