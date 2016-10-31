package testbed.participants;

import jason.asSemantics.Unifier;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import jason.bb.BeliefBase;
import jason.bb.ChainBBAdapter;

import java.util.Iterator;
import java.util.List;

/**
 * Customised version of Belief Base where only the most recent step annot is stored.
 * 
 * @author jomi
 */
public class TimedBB extends ChainBBAdapter {
    
    public static final String timeAnnotFunctor = "step";
    
    public TimedBB() { }
    public TimedBB(BeliefBase next) {
        super(next);
    }
    
	@Override
	public boolean add(Literal bel) {
	    if (nextBB.add(bel)) {
	        if (bel.hasAnnot()) {
	            List<Term> newTimeAnnots = bel.getAnnots(timeAnnotFunctor);
	            if (!newTimeAnnots.isEmpty()) {
    	            Term lastTimeAnnot = newTimeAnnots.get(0);
    	            Iterator<Literal> i = getCandidateBeliefs(bel, null);
    	            if (i != null) {
    	                Unifier un = new Unifier();
    	                while (i.hasNext()) {
    	                    Literal linbb = i.next();
    	                    
    	                    if (un.unifies(bel, linbb)) {
            	                // find annots to delete
            	                for (Term t: linbb.getAnnots(timeAnnotFunctor)) {
                                    if (!t.equals(lastTimeAnnot)) {
                                        //System.out.println("removing annot "+t+" from "+linbb+" new step is "+lastTimeAnnot);
                                        linbb.delAnnot(t);
                                    }    	                    
            	                }
            	                break; // the while loop
    	                    }
    	                }
    	            }
	            }
	        }
	        
	        return true;
	    } else {
	        return false;
	    }
	}

	// to test
    /*
	public static void main(String[] args) {
        BeliefBase bb = new TimedBB(new IndexedBB());
        bb.add(Literal.parseLiteral("a(33)[x,step(0),step(1)]"));
        bb.add(Literal.parseLiteral("a(33)[x,step(2)]"));
        bb.add(Literal.parseLiteral("a(33)[x,step(3)]"));
        System.out.println(bb);
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
    */
    
}
