// Environment code for project ClassWork.mas2j

import jason.asSyntax.*;
import jason.environment.*;
import java.util.logging.*;

public class my_env extends Environment {
	
	public static final Term    move = Literal.parseLiteral("move");

    private Logger logger = Logger.getLogger("ClassWork.mas2j."+my_env.class.getName());

    /** Called before the MAS execution with the args informed in .mas2j */
    @Override
    public void init(String[] args) {
        super.init(args);
        addPercept(Literal.parseLiteral("a"));
    }

    @Override
    public boolean executeAction(String agName, Structure action) {
        if (action.equals(move)) {
                logger.info("executing move yeppa yeppa");
            }
		return true;
    }
	

    /** Called before the end of MAS execution */
    @Override
    public void stop() {
        super.stop();
    }
}

