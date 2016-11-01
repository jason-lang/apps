package env;

import jason.asSemantics.Agent;
import jason.asSemantics.Event;
import jason.asSemantics.Intention;
import jason.asSyntax.Literal;
import jason.asSyntax.Trigger;
import jason.asSyntax.Trigger.TEOperator;
import jason.asSyntax.Trigger.TEType;
import jason.bb.BeliefBase;

import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;

public class CustomBUF extends Agent {

    Literal cartagoAnnot = Literal.parseLiteral("percept_type(\"obs_prop\")");
    
    @Override
    public void buf(List<Literal> percepts) {
        if (percepts == null) {
            return;
        }
        
        // deleting percepts in the BB that is not perceived anymore
        Iterator<Literal> perceptsInBB = getBB().getPercepts();
        while (perceptsInBB.hasNext()) { 
            Literal l = perceptsInBB.next();
            
            // ignore CARTAGO perceptions (***** THIS is different from Jason implementation *******)
            if (l.hasAnnot(cartagoAnnot))
                continue;

            // could not use percepts.contains(l), since equalsAsTerm must be
            // used (to ignore annotations)
            boolean wasPerceived = false;
            Iterator<Literal> ip = percepts.iterator();
            while (ip.hasNext()) {
                Literal t = ip.next();
                
                // if perception t is already in BB
                if (l.equalsAsStructure(t) && l.negated() == t.negated()) {
                    wasPerceived = true;
                    // remove in percepts, since it already is in BB 
                    // [can not be always removed, since annots in this percepts should be added in BB
                    //  Jason team for AC, for example, use annots in perceptions]
                    if (!l.hasAnnot())
                        ip.remove();
                    break;
                }
            }
            if (!wasPerceived) {
                // new version (it is sure that l is in BB, only clone l when the event is relevant)
                perceptsInBB.remove(); // remove l as perception from BB
                
                Trigger te = new Trigger(TEOperator.del, TEType.belief, l);
                if (ts.getC().hasListener() || pl.hasCandidatePlan(te)) {
                    l = l.copy();
                    l.clearAnnots();
                    l.addAnnot(BeliefBase.TPercept);
                    te.setLiteral(l);
                    ts.getC().addEvent(new Event(te, Intention.EmptyInt));
                }
            }
        }

        // BUF only adds a belief when appropriate
        // checking all percepts for new beliefs
        for (Literal lp : percepts) {
            try {
                lp = lp.copy().forceFullLiteralImpl();
                lp.addAnnot(BeliefBase.TPercept);
                if (getBB().add(lp)) {
                    Trigger te = new Trigger(TEOperator.add, TEType.belief, lp);
                    ts.updateEvents(new Event(te, Intention.EmptyInt));
                }
            } catch (Exception e) {
                logger.log(Level.SEVERE, "Error adding percetion " + lp, e);
            }
        }
    }
}
