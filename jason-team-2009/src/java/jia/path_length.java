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
 * Computes the distance between location based on A*
 * 
 * Use: jia.path_length(+Sx, +Sy, +Tx, +Ty, -D [, fences] )
 * where S is the starting point and T the targed. D is the distance.
 * if the last argument is "fences", fences are considered as obstacles
 * 
 * @author jomi
 */
public class path_length extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        try {
            LocalWorldModel model = ((CowboyArch)ts.getUserAgArch()).getModel();
    
            int iagx = (int)((NumberTerm)terms[0]).solve();
            int iagy = (int)((NumberTerm)terms[1]).solve();
            int itox = (int)((NumberTerm)terms[2]).solve();
            int itoy = (int)((NumberTerm)terms[3]).solve();
            
            
            if (model.inGrid(itox,itoy)) {
                
                // destination should be a free place
                while (!model.isFreeOfObstacle(itox,itoy) && itox > 0) itox--;
                while (!model.isFreeOfObstacle(itox,itoy) && itox < model.getWidth()) itox++;

                Location from = new Location(iagx, iagy);
                Location to   = new Location(itox, itoy);
                
                boolean fencesAsObs = terms.length > 5  && terms[5].toString().equals("fences");
                int dist = model.pathLength(from, to, fencesAsObs, ts.getUserAgArch());
                if (dist >= 0) {
                    return un.unifies(terms[4], new NumberTermImpl(dist));
                } else if (!fencesAsObs) {
                    ts.getLogger().info("No route from "+from+" to "+to+"!");
                }
                /*
                Nodo solution = new Search(model, from, to, null, false, false, false, false, false, fencesAsObs, ts.getUserAgArch()).search();
                if (solution != null) {
                    int length = solution.getProfundidade();
                    //ts.getLogger().info("path length from "+from+" to "+to+" = "+length+" path="+solution.montaCaminho());
                    return un.unifies(terms[4], new NumberTermImpl(length));
                } else if (!fencesAsObs) {
                    ts.getLogger().info("No route from "+from+" to "+to+"!");
                }
                */
            }
        } catch (Throwable e) {
            ts.getLogger().log(Level.SEVERE, "jia.path_length error: "+e, e);
        }
        return false;
    }
}
