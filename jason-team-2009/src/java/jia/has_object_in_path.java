package jia;

import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.List;

import arch.CowboyArch;
import arch.LocalWorldModel;
import busca.Nodo;
import env.WorldModel;

/** 
 * Gives the distance from current location to an object considering a destination 
 * Uses A* for this task.
 *  
 * @author jomi
 */
public class has_object_in_path extends direction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        CowboyArch arch = (CowboyArch)ts.getUserAgArch();
        LocalWorldModel model = arch.getModel();

        Nodo solution = findPath(ts, terms);
        if (solution != null) {
            int object = WorldModel.stringToObject( terms[4].toString().toUpperCase() );
            if (object < 0) {
                ts.getLogger().info("*********** The object "+ terms[4]+" is not recognised as a valid object!");
                return false;
            }
            List<Nodo> path = Search.normalPath(solution);
            for (Nodo n: path) {
                Location l = Search.getNodeLocation(n);
                if (model.hasObject(object, l)) {
                    return
                        un.unifies( terms[5], ASSyntax.createNumber( l.x )) &&
                        un.unifies( terms[6], ASSyntax.createNumber( l.y )) &&
                        un.unifies( terms[7], ASSyntax.createNumber( n.getProfundidade() ));
                }
            }
        } else {
            ts.getLogger().info("No route from "+ terms[0]+","+terms[1] +" to "+ terms[2]+","+terms[3]+" to detect whether there is some object!");            
        }
        return false;
    }
}

