// Internal action code for project smadasMAPC2013

package ia;

import env.MixedAgentArch;
import graphLib.Graph;
import graphLib.Island;

import java.util.List;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class getIslands extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        final Graph graph = arch.getGraph();
        
        int amount = (int) ((NumberTerm) args[0]).solve();
        VarTerm islandsTerm = ((VarTerm) args[1]);
        
        List<Island> islands = graph.getAllIslands(amount);
        
        
        //List of all islands
		ListTerm listIslands = new ListTermImpl();
        ListTerm tailIslands = listIslands;
        
        for (Island cIsland : islands) {
	        	Literal islandLiteral = new LiteralImpl("island");
	        	
	        	islandLiteral.addTerm(new Atom(graph.integer2vertex[cIsland.getCutVertex()]));
	        	
	        	//List of all vertices in the island
	        	
	    		ListTerm listVertices = new ListTermImpl();
	            ListTerm tailVertices = listVertices;
	        	for (int v : cIsland.getVertices()) {
	        		tailVertices = tailVertices.append(new Atom(graph.integer2vertex[v]));
	        	}
	        	
	        	islandLiteral.addTerm(listVertices);
	        	islandLiteral.addTerm(new NumberTermImpl(cIsland.getValue()));
	        	
	            tailIslands = tailIslands.append(islandLiteral);
        }
        
        un.bind(islandsTerm, listIslands);
        
        return true;
    }
}
