package ia;

import graphLib.GlobalGraph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class remEnemyPosition extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        
    	GlobalGraph graph = GlobalGraph.getInstance();
    	
    	int id = (int) ((NumberTerm) args[0]).solve();
    	String enemy = unQuote(args[1].toString());
    	graph.remEnemyPosition(id, enemy);
    	
        return true;
    }
    
    private String unQuote(String str) {
    	if (str.charAt(0) == '"' && str.charAt(str.length()-1) == '"' )
            return str.substring(1, str.length()-1);
    	return str;
    }
}
