// Environment code for project a.mas2j

import jason.asSyntax.*;
import jason.environment.*;
import java.util.logging.*;

public class testEnv extends Environment {

    private Logger logger = Logger.getLogger("a.mas2j."+testEnv.class.getName());

    /** Called before the MAS execution with the args informed in .mas2j */
    @Override
    public void init(String[] args) {
        super.init(args);
        addPercept(Literal.parseLiteral("percept(demo)"));
    }

    @Override
    public boolean executeAction(String agName, Structure action) {
        try { Thread.sleep(2000); } catch (Exception e) {}
        logger.info("doing action "+action);
		return true;
    }

    /** Called before the end of MAS execution */
    @Override
    public void stop() {
        super.stop();
    }
}

