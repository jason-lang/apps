package artifacts;

import jason.asSyntax.Atom;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.StringTermImpl;
import jason.asSyntax.Term;
import java.util.HashMap;
import java.util.Map;

import ora4mas.nopl.JasonTermWrapper;

import cartago.*;

public class InspectArtifact extends Artifact {
    private Map<String, ObsProperty> entityToObs = new HashMap<String, ObsProperty>();
    private Map<String, ObsProperty> suspectsToObs = new HashMap<String, ObsProperty>();
    
    public void init() {}
    
    @OPERATION
    void addEntity(String entity, String type, int maxHealth, int strength, int visRange) {
        if (entityToObs.containsKey(entity)) return;
        
        Term entityTerm;
        if (entity.substring(0, 1).equals(entity.substring(0, 1).toUpperCase())) {
            entityTerm = new StringTermImpl(entity);
        } else {
            entityTerm = new Atom(entity);
        }
        
        Term typeTerm = new StringTermImpl(type);
        
        Term maxHealthTerm = new NumberTermImpl(maxHealth);
        
        Term maxStrengthTerm = new NumberTermImpl(strength);
        
        Term maxVisRangeTerm = new NumberTermImpl(visRange);
        
        //Add the new observable property
        Object[] o = getTermsAsProlog(entityTerm, typeTerm, maxHealthTerm, maxStrengthTerm, maxVisRangeTerm);
        defineObsProperty("entityType", o);
        entityToObs.put(entity, getObsPropertyByTemplate("entityType", o));
    }
    
    @OPERATION
    void setSuspect(String entity) {
        Term entityTerm;
        if (entity.substring(0, 1).equals(entity.substring(0, 1).toUpperCase())) {
            entityTerm = new StringTermImpl(entity);
        } else {
            entityTerm = new Atom(entity);
        }
        
        if (!suspectsToObs.containsKey(entity)) {
            //Add the new observable property
            Object[] o = getTermsAsProlog(entityTerm);
            defineObsProperty("suspect", o);
            suspectsToObs.put(entity, getObsPropertyByTemplate("suspect", o));          
        }
    }
    
    @OPERATION
    void unsetSuspect(String entity) {
        //Remove the suspect
        ObsProperty obsOld = suspectsToObs.get(entity);
        if (obsOld != null) {
            suspectsToObs.remove(entity);
            removeObsPropertyByTemplate(obsOld.getName(), obsOld.getValues());
        }
    }
    
    @OPERATION
    void reset() {
        //Remove all observable properties
        for (Map.Entry<String, ObsProperty> entityObs : entityToObs.entrySet()) {
            ObsProperty p = entityObs.getValue();
            removeObsPropertyByTemplate(p.getName(), p.getValues());
        }
        for (Map.Entry<String, ObsProperty> entityObs : suspectsToObs.entrySet()) {
            ObsProperty p = entityObs.getValue();
            removeObsPropertyByTemplate(p.getName(), p.getValues());
        }    
        entityToObs.clear();
        suspectsToObs.clear();
    }
    
    private Object[] getTermsAsProlog(Term... o) {
        Object[] terms = new Object[o.length];
        int i = 0;
        for (Term t : o)
            terms[i++] = new JasonTermWrapper(t);

        return terms;
    }
}

