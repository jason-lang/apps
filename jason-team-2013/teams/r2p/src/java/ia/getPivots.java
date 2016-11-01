package ia;

import java.util.List;
import env.MixedAgentArch;
import graphLib.Graph;
import graphLib.PairPivot;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class getPivots extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        final Graph graph = arch.getGraph();
        
        int amount = (int) ((NumberTerm) args[0]).solve();
        VarTerm pivotsTerm = ((VarTerm) args[1]);
        
        List<PairPivot> pivots = graph.getAllPivots(amount);
        
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
