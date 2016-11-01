// Internal action code for project smadasMAPC2012

package ia;

import graphLib.GlobalGraph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class cleanPosition extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        
    	GlobalGraph graph = GlobalGraph.getInstance();
    	
    	int id = (int) ((NumberTerm) args[0]).solve();
    	String vertex = args[1].toString();
    	graph.cleanPosition(id, vertex);
    	
        return true;
    }
}
