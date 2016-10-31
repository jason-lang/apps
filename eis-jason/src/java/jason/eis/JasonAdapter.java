package jason.eis;
import jason.JasonException;
import jason.asSyntax.Literal;
import jason.environment.Environment;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import eis.EIDefaultImpl;
import eis.exceptions.ActException;
import eis.exceptions.ManagementException;
import eis.exceptions.NoEnvironmentException;
import eis.exceptions.PerceiveException;
import eis.iilang.Action;
import eis.iilang.Parameter;
import eis.iilang.Percept;

/**
 * Class that adapts a Jason Environment as a EIS environment
 * 
 * @author jomi
 */
public abstract class JasonAdapter extends EIDefaultImpl {

    protected Environment jasonEnv = null; // a sub-class will instantiate this

    /** 
     * For jason, only values are used, keys have to be different values
     */
    @Override
    public void init(Map<String, Parameter> parameters) throws ManagementException {
        super.init(parameters);
        String[] args = new String[parameters.size()];
        int i=0;
        for (Parameter p: parameters.values()) {
            args[i++] = p.toProlog();
        }
        jasonEnv.init( args );
    }

    @Override
    public void kill() throws ManagementException {
        super.kill();
        jasonEnv.stop();
    }
    
    private Map<String, List<Literal>> previousPerception = new HashMap<String, List<Literal>>();
    
    @Override
    protected LinkedList<Percept> getAllPerceptsFromEntity(String ent) throws PerceiveException, NoEnvironmentException {
        LinkedList<Percept> eisPer = new LinkedList<Percept>();
        List<Literal> lper = jasonEnv.getPercepts(ent);
        if (lper == null) { // no changes in the perception for ent
            lper = previousPerception.get(ent);
        } else {
            lper = previousPerception.put(ent, lper);
        }
        if (lper != null)
            for (Literal jasonPer: lper) 
                eisPer.add( Translator.literalToPercept( jasonPer ));
        
        //System.out.println("perceptions for "+ent+" are "+eisPer);
        return eisPer;
        
    }
    
    @Override
    protected Percept performEntityAction(String agent, Action action) throws ActException {
        try {
            boolean ok = jasonEnv.executeAction(agent, Translator.actoinToStructure(action) );
            if (!ok)
                throw new ActException("error executing action "+action.toProlog());
        } catch (JasonException e) {
            e.printStackTrace();
            throw new ActException(e.getMessage());
        }
        return null;
    }
    
    
    @Override
    public String requiredVersion() {
        return "0.3";
    }
}
