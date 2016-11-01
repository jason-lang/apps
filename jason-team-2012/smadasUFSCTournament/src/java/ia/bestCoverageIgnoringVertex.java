// Internal action code for project smadasMAPC2012

package ia;

import java.util.List;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class bestCoverageIgnoringVertex extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        
        int depth = (int) ((NumberTerm) terms[0]).solve();
        String vertexIgnore = ((Atom) terms[1]).getFunctor();
        VarTerm bestVertex = ((VarTerm) terms[2]);
        VarTerm bestValue = ((VarTerm) terms[3]);
        
        List<String> result = graph.getBestCoverage(depth, vertexIgnore);
        
        if (result != null) {

            un.unifiesNoUndo(bestVertex, new Atom(result.get(0)));
            un.unifiesNoUndo(bestValue, new NumberTermImpl(Integer.valueOf(result.get(1))));
            
            return true;
        } else {
            throw new JasonException("There is not best coverage yet");
        }
        
        
    }
}
