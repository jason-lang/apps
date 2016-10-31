import jason.eis.JasonAdapter;
import eis.exceptions.EntityException;
import eis.iilang.Action;


public class EISHouseEnv extends JasonAdapter {

    public EISHouseEnv() {
        jasonEnv = new HouseEnv(); // create the instance of Jason Environment
        try {
            addEntity("robot");
            addEntity("owner");
            addEntity("supermarket");
        } catch (EntityException e) {
            e.printStackTrace();
        }
    }
    
    @Override
    protected boolean isSupportedByEntity(Action arg0, String arg1) {
        return true;
    }
    
    @Override
    protected boolean isSupportedByEnvironment(Action arg0) {
        return true;
    }
    
    @Override
    protected boolean isSupportedByType(Action arg0, String arg1) {
        return true;
    }
}
