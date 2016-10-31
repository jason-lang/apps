// Environment code for project testeWait.mas2j

import jason.asSyntax.*;
import jason.environment.*;
import java.util.logging.*;

public class env extends jason.environment.Environment {

	private Logger logger = Logger.getLogger("testeWait.mas2j."+env.class.getName());

	public env() {
		addPercept(Literal.parseLiteral("percept(demo)"));
	}

	public boolean executeAction(String ag, Structure action) {
		logger.info("executing: "+action);
		addPercept(Literal.parseLiteral("c(18)"));
		return true;
	}
}

