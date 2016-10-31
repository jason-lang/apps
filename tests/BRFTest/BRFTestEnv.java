import jason.asSyntax.*;
import jason.environment.*;

public class BRFTestEnv extends Environment
{ //class
	
	public static final Literal iInfo = Literal.parseLiteral("info");
	
	public boolean executeAction(String pAgentName, Structure pAction)
	{ //boolean
		
		if (pAction.getFunctor().equals("get_info_as_percept"))
		{ //if
			
			addPercept( pAgentName, Literal.parseLiteral("info") );
			
		} //if
		
		else if (pAction.getFunctor().equals("clear_my_percepts"))
		{ //if
			
			clearPercepts(pAgentName);
			
		} //if
		
	    informAgsEnvironmentChanged();
	    
		return true;
		
	} //boolean
	
} //class