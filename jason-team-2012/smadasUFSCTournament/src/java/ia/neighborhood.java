// Internal action code for project smadasMAPC2012

package ia;

import env.MixedAgentArch;
import graphLib.Graph;

import java.util.List;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class neighborhood extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        
        String vertexS = ((Atom) terms[0]).getFunctor();
        int depth = (int)((NumberTerm) terms[1]).solve();
        VarTerm listOfNeighbors = ((VarTerm) terms[2]);
        
        List<String> neightborhood = graph.getNeighborhood(vertexS, depth);
        
        if (neightborhood != null && neightborhood.size() > 0) {
            ListTerm list = new ListTermImpl();
            ListTerm tail = list;
            for (String s : neightborhood) {
                tail = tail.append(new Atom(s));
            }
            
            un.bind(listOfNeighbors, list);
            
            return true;
        } else {
            throw new JasonException("There is not neighborhood for the vertex");
        }
    }
}
