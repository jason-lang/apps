package mds;

import jason.asSemantics.*;
import jason.asSyntax.*;
import java.util.*;

/** example of agent function overriding */
public class MDSAgent extends Agent {

	/** unattendedLuggage event has priority */
	public Event selectEvent(List evList) {
		Iterator i = evList.iterator();
		while (i.hasNext()) {
			Event e = (Event) i.next();
			if (e.getTrigger().getFunctor().equals("unattended_luggage")) {
				i.remove();
				return e;
			}
			// the unattended Luggage event could generate a
			// sub-goal that generates other events 
			if (e.getIntention() != null) {
				Iterator j = e.getIntention().iterator();
				while (j.hasNext()) {
					IntendedMeans im = (IntendedMeans) j.next();
					Trigger it = (Trigger) im.getPlan().getTriggerEvent();
					if (it.getFunctor().equals("unattended_luggage")) {
						i.remove();
						return e;
					}
				}
			}
		}
		return super.selectEvent(evList);
	}
}
