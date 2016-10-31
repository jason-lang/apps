// Environment code for project TestJade.mas2j

import jason.asSyntax.*;
import jason.environment.*;
import java.util.logging.*;

public class TestEnv extends jason.environment.Environment {

    private Logger logger = Logger.getLogger("TestJade.mas2j."+TestEnv.class.getName());

    /** Called before the MAS execution with the args informed in .mas2j */
    @Override
    public void init(String[] args) {
        if (args.length > 0) {
            addPercept(Literal.parseLiteral("percept("+args[0]+")"));
            logger.info(args[0]);
        } else {
            addPercept(Literal.parseLiteral("percept(demo)"));
            logger.info("demo");
        }
    }

    @Override
    public boolean executeAction(String ag, Structure action) {
        logger.info("executing: "+action+", but not implemented!");
        return true;
    }

    /** Called before the end of MAS execution */
    @Override
    public void stop() {
		super.stop();
		logger.info("Stopping user environment!");
    }
}

