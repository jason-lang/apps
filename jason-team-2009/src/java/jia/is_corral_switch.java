package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import arch.CowboyArch;
import arch.LocalWorldModel;
import env.WorldModel;

/**
 * verifies wither a switch is the corral switch
 * 
 * @author jomi
 */
public class is_corral_switch extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) {
        LocalWorldModel model = ((CowboyArch)ts.getUserAgArch()).getModel();
        int sx = (int)((NumberTerm)args[0]).solve();
        int sy = (int)((NumberTerm)args[1]).solve();
        //ts.getLogger().info("yyyy "+model.getCorral().distanceMaxBorder(new Location(sx, sy))+" - "+model.getCorral() + " - " + new Location(sx, sy));
        if (model.hasObject(WorldModel.CORRAL, sx+1, sy)) return true;
        if (model.hasObject(WorldModel.CORRAL, sx-1, sy)) return true;
        if (model.hasObject(WorldModel.CORRAL, sx, sy+1)) return true;
        if (model.hasObject(WorldModel.CORRAL, sx, sy-1)) return true;
        return false;
        //return model.getCorral().distanceMaxBorder(new Location(sx, sy)) == 1;
    }
}
