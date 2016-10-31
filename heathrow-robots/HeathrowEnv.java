
import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import jason.environment.Environment;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HeathrowEnv extends Environment {
   
	Literal[] initialLocations = { Literal.parseLiteral("location(t1,g1)"), Literal.parseLiteral("location(t1,g2)"), Literal.parseLiteral("location(t1,g3)")};
	Map agsLocation = new HashMap();
	
    public HeathrowEnv() {
        clearPercepts();
        
        // Add initial percepts below, for example:
        addPercept(Literal.parseLiteral("unattended_luggage(t1,g3,1)") );
        addPercept("mds1", initialLocations[1]);
    }
    
    /**
     * Implementation of the agents' basic actions
     */
    public boolean executeAction(String ag, Term action) {
        if (action.getFunctor().equals("place_bid")) {
            Integer x = new Integer(action.getTerm(2).toString());
            //bid.put(ag,x);
        }
        
        return true;
    }
}
