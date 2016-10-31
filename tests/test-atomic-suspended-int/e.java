// Environment code for project tactat.mas2j

import jason.asSyntax.*;
import jason.environment.*;
import java.util.logging.*;

public class e extends Environment {

    private Logger logger = Logger.getLogger("tactat.mas2j."+e.class.getName());

    /** Called before the MAS execution with the args informed in .mas2j */
    @Override
    public void init(String[] args) {
        addPercept(Literal.parseLiteral("percept(demo)"));
    }

    @Override
    public boolean executeAction(String agName, Structure action) {
        logger.info("executing: "+action+", but not implemented!");
        try { Thread.sleep(2000); } catch (Exception e) {}
        logger.info("DONE!");
        return true;
    }

    /** Called before the end of MAS execution */
    @Override
    public void stop() {
        super.stop();
    }
}

