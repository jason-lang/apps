package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.logging.Level;

import arch.CowboyArch;
import arch.LocalWorldModel;

/** 
 *  Gives a good location for the scouter
 *
 *  jia.scouter_pos( LeaderPos, LeaderTarget, Return).
 *  
 *  Example: jia.scouter_pos( 2,2, 5,6, X, Y)
 *  
 *  @author jomi
 */
public class scouter_pos extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        try {
            CowboyArch arch       = (CowboyArch)ts.getUserAgArch();
            LocalWorldModel model = arch.getModel();
            if (model == null)
                return false;
            
            int lx = (int)((NumberTerm)args[0]).solve();
            int ly = (int)((NumberTerm)args[1]).solve();
            int tx = (int)((NumberTerm)args[2]).solve();
            int ty = (int)((NumberTerm)args[3]).solve();
            Location leaderPos    = new Location(lx, ly);
            Location leaderTarget = new Location(tx, ty);

            Location agTarget = getScouterTarget(model, leaderPos, leaderTarget);
            if (agTarget != null) {
                return un.unifies(args[4], new NumberTermImpl(agTarget.x)) && 
                       un.unifies(args[5], new NumberTermImpl(agTarget.y));
            } else {
                ts.getLogger().info("No target for scouter!");
            }
        } catch (Throwable e) {
            ts.getLogger().log(Level.SEVERE, "scouter_pos error: "+e, e);           
        }
        return false;
    }
    
    public Location getScouterTarget(LocalWorldModel model, Location leaderPos, Location leaderTarget) throws Exception {
        Vec leader = new Vec(model, leaderPos);
        Vec target = new Vec(model, leaderTarget).sub(leader);
        Vec me     = new Vec(model.agPerceptionRatio*2-3,0);
        return model.nearFree(herd_position.findFirstFreeLocTowardsTarget(target, me, leader, true, model), null);
    }
}

