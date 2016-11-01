// Internal action code for project smadasMAPC2013

package ia;

import java.util.ArrayList;
import java.util.List;

import env.MixedAgentArch;
import graphLib.Graph;
import graphLib.PairPivot;
import graphLib.PivotAlgorithm;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class getPivots extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        final Graph graph = arch.getGraph();
        
        int amount = (int) ((NumberTerm) args[0]).solve();
        VarTerm pivotsTerm = ((VarTerm) args[1]);
        
        List<String> pivots = graph.getAllPivots(amount);
        
		ListTerm list = new ListTermImpl();
        ListTerm tail = list;
        
        String mainPivot = null;
        for (String s : pivots) {
        	if (mainPivot == null) {
        		mainPivot = s;
        	} else {
	        	Literal pivotLiteral = new LiteralImpl("pivot");
	        	
	        	pivotLiteral.addTerm(new Atom(mainPivot));
	        	pivotLiteral.addTerm(new Atom(s));
	            tail = tail.append(pivotLiteral);
            
	            mainPivot = null;
        	}
        }
		
		un.bind(pivotsTerm, list);
        
        return true;
    }
}
