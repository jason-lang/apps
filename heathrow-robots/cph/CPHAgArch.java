package cph;

import jason.architecture.CentralisedAgArch;
import jason.asSemantics.Message;
import jason.asSyntax.Term;

import java.util.Iterator;
import java.util.List;

public class CPHAgArch extends CentralisedAgArch {

	/** overridden to ignore bid messages */
	public void checkMail() {
		List mbox = (List) fEnv.getAgMbox(getName());
		synchronized (mbox) {
			Iterator i = mbox.iterator();
			while (i.hasNext()) {
				Message im = (Message) i.next();
				if (!im.getPropCont().startsWith("bid")) {
					fTS.getC().getMB().add(im);
					if (fTS.getSettings().verbose() >= 1) {
						System.out.println("Agent " + getName() + " received message: " + im);
					}
				}
				i.remove();
			}
		}
	}

	public void act() {
		// get the action to be performed
		if (fTS.getC().getAction() != null) {
			Term action = fTS.getC().getAction().getActionTerm();
			if (!action.getFunctor().equals("disarm")) {
				if (fEnv.getUserEnvironment().executeAction(getName(), action)) {
					fTS.getC().getAction().setResult(true);
				} else {
					fTS.getC().getAction().setResult(false);
				}
				fTS.getC().getFeedbackActions().add(fTS.getC().getAction());
			}
		}
	}
}
