// Environment code for project t.mas2j

import jason.asSyntax.*;
import jason.environment.*;
import java.util.logging.*;

public class Envv extends jason.environment.Environment {

    private Logger logger = Logger.getLogger("t.mas2j."+Envv.class.getName());

    /** Called before the MAS execution with the args informed in .mas2j */
    @Override
    public void init(String[] args) {
		new Thread() {
			public void run() {
				int i=0;
				while (true) {
					addPercept(Literal.parseLiteral("v("+i+")"));
					informAgsEnvironmentChanged();
					i++;
					try { sleep(500); } catch (Exception e) {}
				}
			}
		}.start();
    }

    @Override
    public boolean executeAction(String agName, Structure action) {
        logger.info("executing: "+action+", but not implemented!");
        return true;
    }

    /** Called before the end of MAS execution */
    @Override
    public void stop() {
        super.stop();
    }
}

