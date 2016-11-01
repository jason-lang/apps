// Internal action code for project smadasMAPC2012

package ia;

import java.util.List;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class shortestPath extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        
        String vertexS = ((Atom) terms[0]).getFunctor();
        String vertexD = ((Atom) terms[1]).getFunctor();
        VarTerm path = ((VarTerm) terms[2]);
        VarTerm lenght = ((VarTerm) terms[3]);
        
        List<String> shortestPath = graph.getShortestPath(vertexS, vertexD);
        
        if (shortestPath != null && shortestPath.size() > 0) {
            ListTerm list = new ListTermImpl();
            ListTerm tail = list;
            for (String s : shortestPath) {
                tail = tail.append(new Atom(s));
            }
            
            un.bind(path, list);
            un.unifiesNoUndo(lenght, new NumberTermImpl(shortestPath.size()));
            
            return true;
        } else {
            throw new JasonException("There is not way");
        }
    }
}
