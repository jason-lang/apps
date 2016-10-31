package agent;

import jason.asSemantics.Agent;
import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.bb.DefaultBeliefBase;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Customised version of Belief Base where some beliefs are unique (with primary keys).
 * 
 * <p>E.g.:<br/>
 * <code>beliefBaseClass agent.UniqueBelsBB("student(key,_)", "depot(_,_,_)")</code>
 * <br/>
 * The belief "student/2" has the first argument as its key, so the BB will never has
 * two students with the same key. Or, two students in the BB will have two different keys.
 * The belief "depot/3" has no key, so there will be always only one "depot" in the BB.
 * 
 * @author jomi
 */
public class UniqueBelsBB extends DefaultBeliefBase {
    //static private Logger logger = Logger.getLogger(UniqueBelsBB.class.getName());

    Map<String,Literal> uniqueBels = new HashMap<String,Literal>();
    Unifier             u = new Unifier();
    Agent               myAgent;
    
    public void init(Agent ag, String[] args) {
        this.myAgent = ag;
    	for (int i=0; i<args.length; i++) {
    		Literal arg = Literal.parseLiteral(args[i]);
    		uniqueBels.put(arg.getFunctor(), arg);
    	}
    }

	@Override
	public boolean add(Literal bel) {
		Literal kb = uniqueBels.get(bel.getFunctor());
		if (kb != null && kb.getArity() == bel.getArity()) { // is a constrained bel?
			
			// find the bel in BB and eventually remove it
			u.clear();
			Literal linbb = null;
			boolean remove = false;

			Iterator<Literal> relevant = getCandidateBeliefs(bel, null);
			if (relevant != null) {
			    final int kbArity = kb.getArity();
				while (relevant.hasNext() && !remove) {
					linbb = relevant.next();

					// check equality of all terms that are "key"
					// if some key is different, no problem
					// otherwise, remove the current bel
					boolean equals = true;
					for (int i = 0; i<kbArity; i++) {
						Term kbt = kb.getTerm(i);
						if (!kbt.isVar()) { // is key?
							if (!u.unifies(bel.getTerm(i), linbb.getTerm(i))) {
								equals = false;
								break;
							}
						}
					}
					// TODO: prefer source(percept) info
					if (equals) {
						remove = true;
					}
				}
			}
			if (remove) {
				remove(linbb);
			}
		}
		return super.add(bel);
	}
	
	public void remove_old_bels(Literal bel, String timeAnnot, int maxAge, int curAge) {
        Iterator<Literal> relevant = getCandidateBeliefs(bel, null);
        if (relevant != null) {
            List<Literal> toDel = new ArrayList<Literal>();
            while (relevant.hasNext()) {
                Literal linbb = relevant.next();

                // find greatest timeAnnot
                Structure bTime = null;
                if (linbb.hasAnnot()) {
                    for (Term t: linbb.getAnnots()) {
                        if (t.isStructure()) {
                            Structure s = (Structure)t;
                            if (s.getFunctor().equals(timeAnnot)) {
                                if (bTime == null) {
                                    bTime = s;
                                } else if (bTime.compareTo(s) < 0) {
                                    linbb.delAnnot(bTime); // remove old time annot
                                    bTime = s;
                                }
                            }
                        }
                    }
                    
                    // if bTime was found
                    if (bTime != null) {
                        int age = (int)((NumberTerm)bTime.getTerm(0)).solve();
                        if (curAge - age > maxAge)
                            toDel.add(linbb);
                    }
                }
            }
            for (Literal l: toDel) {
                myAgent.getLogger().info("Removing "+l+" from BB because it is too old (current step is "+curAge+")");
                remove(l);
            }
        }
	}
	
}
