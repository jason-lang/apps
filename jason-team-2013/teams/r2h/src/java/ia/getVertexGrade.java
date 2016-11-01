// Internal action code for project smadasMAPC2013

package ia;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class getVertexGrade extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        final Graph graph = arch.getGraph();
        
        final Term vertex = args[0];
        
        int result = graph.getGrade(((Atom) vertex).getFunctor());
        return un.unifiesNoUndo(args[1], new NumberTermImpl(result));
    }
}
