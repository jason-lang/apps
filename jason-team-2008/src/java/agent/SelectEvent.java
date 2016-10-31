
package agent;

import jason.asSemantics.Agent;
import jason.asSemantics.Event;
import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;
import jason.asSyntax.Trigger;

import java.util.Iterator;
import java.util.List;
import java.util.Queue;

/**
 * change the default select event function to prefer +cow(_,_,_) events.
 * 
 * @author Jomi
 */
public class SelectEvent extends Agent {

    private Trigger cow  = Trigger.parseTrigger("+cow(_,_,_)");
    private Unifier un   = new Unifier();
    private boolean cleanCows = false;

    public Event selectEvent(Queue<Event> events) {
        Iterator<Event> ie = events.iterator();
        while (ie.hasNext()) {
            un.clear();
            Event e = ie.next();
            if (un.unifies(cow, e.getTrigger())) {
                ie.remove();
                return e;
            }
        }
        return super.selectEvent(events);
    }
    
    public void cleanCows() {
        cleanCows = true;
    }
    
    @Override
    public void buf(List<Literal> percepts) {
        super.buf(percepts);
        if (cleanCows) {
            // remove old cows from the memory
            
            ((UniqueBelsBB)getTS().getAg().getBB()).remove_old_bels(Literal.parseLiteral("cow(x,x,x)"), "step", 6, getTS().getUserAgArch().getCycleNumber());
            cleanCows = false;
        }
    }
}
