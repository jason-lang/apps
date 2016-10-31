package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jason.environment.grid.Location;
import arch.CowboyArch;
import arch.LocalWorldModel;

/** 
 * Computes a place in the other side of a fence
 * 
 * Use: jia.other_side_fence(+Fx, +Fy, -Tx, -Ty )
 * where F if a fence location and T will be the target
 * 
 * @author jomi
 */
public class other_side_fence extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        CowboyArch arch       = (CowboyArch)ts.getUserAgArch();
        LocalWorldModel model = arch.getModel();

        int fx = (int)((NumberTerm)terms[0]).solve();
        int fy = (int)((NumberTerm)terms[1]).solve();
        Vec vtarget = computesOtherSide(model, new Vec(model, model.getAgPos(arch.getMyId())), new Vec(model, fx, fy));
        Location ltarget = vtarget.getLocation(model);
        ltarget = model.nearFree(ltarget, null);
        return 
            un.unifies(terms[2], ASSyntax.createNumber(ltarget.x)) && 
            un.unifies(terms[3], ASSyntax.createNumber(ltarget.y));
    }
    
    public Vec computesOtherSide(LocalWorldModel model, Vec start, Vec fence) {
        return fence.sub(start).product(6).add(start);
    }
}
