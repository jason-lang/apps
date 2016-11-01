// Internal action code for project smadasMAPC2012

package ia;

import env.MixedAgentArch;
import graphLib.GlobalGraph;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class synchronizeGraph extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        Graph graph = arch.getGraph();
        if (graph.getEdges() < graph.getMaxEdges()) {
	        Graph globalGraph = GlobalGraph.getInstance().getGraph();
	        
	        int u, i, v;
	        for (u = 0; u <= graph.getSize(); u++) {
	        	for (i = 0; i < globalGraph.grade[u]; i++) {
	        		v = globalGraph.adj[u][i];
	        		graph.addEdgeSync(u, v, globalGraph.w[u][v]);
	        	}
	        }
        }
        if (arch.isLogOn()) 
        	System.gc(); 
        return true;
    }
}
