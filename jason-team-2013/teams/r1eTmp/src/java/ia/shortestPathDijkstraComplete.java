// Internal action code for project smadasMAPC2012

package ia;

import java.util.LinkedList;
import java.util.List;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class shortestPathDijkstraComplete extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        
		String vertexS = ((Atom) terms[0]).getFunctor();
		VarTerm nearestD = ((VarTerm) terms[2]);
		VarTerm path = ((VarTerm) terms[3]);
		VarTerm lenght = ((VarTerm) terms[4]);
		
		ListTerm vertexD = (ListTerm) terms[1];
		
		List<String> listD = new LinkedList<String>();
		for (Term d : vertexD.getAsList()) {
			listD.add(((Atom) d).getFunctor());
		}
		
		List<String> shortestPath = graph.getShortestPathDijkstraComplete(vertexS, listD);
		
		if (shortestPath != null && shortestPath.size() > 0) {
			ListTerm list = new ListTermImpl();
	        ListTerm tail = list;
	        for (String s : shortestPath) {
	            tail = tail.append(new Atom(s));
	        }
    		
    		un.bind(path, list);
    		un.unifiesNoUndo(lenght, new NumberTermImpl(shortestPath.size()));
    		un.unifiesNoUndo(nearestD, new Atom(shortestPath.get(shortestPath.size()-1)));
    		
    		return true;
		} else {
			throw new JasonException("There is not way");
		}
    }
}
