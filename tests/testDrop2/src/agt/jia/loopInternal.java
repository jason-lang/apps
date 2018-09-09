package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.Term;

public class loopInternal extends DefaultInternalAction {

	private static final long serialVersionUID = 5552929201215381277L;

	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
		
//		while (true) {
//			Thread.sleep(1000);
//		}
		Thread.sleep(1500);
		
		return true;
	}
}
