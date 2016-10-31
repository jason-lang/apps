import java.util.*;
import jason.asSyntax.*;
import jason.environment.*;

public class nrcbpEnv extends Environment {
    
    //static Term a = Literal.parseLiteral("action");
    int c;
    int p;
    
    public nrcbpEnv() {
        // initial global percepts
	c = 1;
	p = 0;
        addPercept(Literal.parseLiteral("cycle(1)"));
    }

    /**
	 * Implementation of the agent's basic actions
	 */
	 @Override
    public boolean executeAction(String ag, Structure act) {
        try {
			System.out.println(act);
            if (act.toString().equals("action") && c<=50) {
		removePercept(Literal.parseLiteral("cycle("+p+")")); 
		addPercept(Literal.parseLiteral("cycle("+c+")"));
		c++;
		p++;
           }
           return true;
        } catch (Exception e) {
            System.err.println("Unexpected agent action");
            e.printStackTrace();
            return false;
        }
    } 
}
