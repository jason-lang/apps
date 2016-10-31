package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.logging.Level;

import env.WorldModel;

import arch.CowboyArch;
import arch.LocalWorldModel;

/**
 * Gets the near least visited location for a location (args 0 and 1) inside an area (arg 2).
 * 
 * Example: jia.near_least_visited(10,10,area(0,0,20,30),X,Y).
 * 
 * Its is based on the agent's model of the world.
 * 
 * @author jomi
 */
public class near_least_visited extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        try {
            LocalWorldModel model = ((CowboyArch)ts.getUserAgArch()).getModel();
            if (model == null) {
                ts.getLogger().log(Level.SEVERE, "no model to get near_least_visited!");
            } else {
                int agx = (int)((NumberTerm)args[0]).solve();
                int agy = (int)((NumberTerm)args[1]).solve();
                Location ag = new Location(agx, agy);
                
                Structure sarea = (Structure)args[2];
                int ax1 = (int)((NumberTerm)sarea.getTerm(0)).solve();
                int ay1 = (int)((NumberTerm)sarea.getTerm(1)).solve();
                int ax2 = (int)((NumberTerm)sarea.getTerm(2)).solve();
                int ay2 = (int)((NumberTerm)sarea.getTerm(3)).solve();
                
                Location tr = new Location(ax1, ay1);
                Location bl = new Location(ax2, ay2);
                
                Location n = model.getNearLeastVisited(ag, tr, bl);
                if (n != null) {
                    Search s = new Search(model, ag, n, ts.getUserAgArch());
                    int loopcount = 0;
                    while (s.search() == null && ts.getUserAgArch().isRunning() && loopcount < 5) {
                        loopcount++;
                        // if search is null, it is impossible in the scenario to goto n, set it as obstacle  
                        ts.getLogger().info("[near least unvisited] No possible path to "+n+" setting as obstacle.");
                        model.add(WorldModel.OBSTACLE, n);
                        n = model.getNearLeastVisited(ag, tr, bl);
                        s = new Search(model, ag, n, ts.getUserAgArch());
                    }
                    
                    un.unifies(args[3], new NumberTermImpl(n.x));
                    un.unifies(args[4], new NumberTermImpl(n.y));
                    //ts.getLogger().info("at "+agx+","+agy+" to "+n.x+","+n.y);
                    return true;
                }
            }
        } catch (Throwable e) {
            ts.getLogger().log(Level.SEVERE, "near_least_visited error: "+e, e);
        }
        return false;
    }
    
    
}
