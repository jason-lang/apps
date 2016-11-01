// Internal action code for project smadasMAPC2012

package ia;

import java.util.LinkedList;
import java.util.List;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class walkAreaSwarm extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        
        String vertexS = ((Atom) terms[0]).getFunctor();
        int borderOut = (int)((NumberTerm) terms[1]).solve();
        int borderIn = (int)((NumberTerm) terms[2]).solve();
        VarTerm listOfNeighborsOutside = ((VarTerm) terms[3]);
        VarTerm listOfNeighborsInside = ((VarTerm) terms[4]);
        
        
        List<String> listInside = new LinkedList<String>();
        List<String> listOutside = new LinkedList<String>();
        
        graph.getNeighborhood(vertexS, borderOut, borderIn, listOutside, listInside);
        
        if (listInside != null && listInside.size() > 0 && listOutside != null && listOutside.size() > 0) {
            ListTerm list = new ListTermImpl();
            ListTerm tail = list;
            for (String s : listInside) {
                tail = tail.append(new Atom(s));
            }
            un.bind(listOfNeighborsInside, list);
            
            ListTerm list2 = new ListTermImpl();
            ListTerm tail2 = list2;
            for (String s : listOutside) {
                tail2 = tail2.append(new Atom(s));
            }
            un.bind(listOfNeighborsOutside, list2);
            
            return true;
        } else {
            throw new JasonException("There is not neighborhood for the vertex");
        }
    }
}
