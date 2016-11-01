// Internal action code for project smadasMAPC2012

package ia;

import java.util.LinkedList;
import java.util.List;

import env.MixedAgentArch;
import graphLib.Graph;
import graphLib.PairPivot;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class getPivotsIgnoringVertices extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
    	
    	MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        final Graph graph = arch.getGraph();
        
        int amount = (int) ((NumberTerm) terms[0]).solve();
		ListTerm verticesIgnore = (ListTerm) terms[1];
		VarTerm pivotsTerm = ((VarTerm) terms[2]);
		
		List<String> listVerticesIgnore = new LinkedList<String>();
		for (Term d : verticesIgnore.getAsList()) {
			listVerticesIgnore.add(((Atom) d).getFunctor());
		}
        
        List<PairPivot> pivots = graph.getAllPivotsIgnoringVertices(amount, listVerticesIgnore);
        
		ListTerm list = new ListTermImpl();
        ListTerm tail = list;
        
        for (PairPivot s : pivots) {
        	Literal pivotLiteral = new LiteralImpl("pivot");
        	
        	pivotLiteral.addTerm(new Atom(graph.integer2vertex[s.getMainVertex()]));
        	pivotLiteral.addTerm(new Atom(graph.integer2vertex[s.getAuxVertex()]));
        	
        	
    		ListTerm listVertices = new ListTermImpl();
            ListTerm tailVertices = listVertices;
        	for (int v : s.getVertices()) {
        		tailVertices = tailVertices.append(new Atom(graph.integer2vertex[v]));
        	}
        	pivotLiteral.addTerm(listVertices);
        	
        	
        	pivotLiteral.addTerm(new NumberTermImpl(s.getValue()));
            tail = tail.append(pivotLiteral);
        }
		
		un.bind(pivotsTerm, list);
		
		return true;
    }
}
