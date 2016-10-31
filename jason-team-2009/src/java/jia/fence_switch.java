package jia;

import java.util.logging.Level;

import arch.CowboyArch;
import arch.LocalWorldModel;
//import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;
import env.WorldModel;


/**
  * Return the position of the switch for a fence.
  * 
  * Use: jia.fence_switch(+Fx,+Fy,-Sx,-Sy)
  * where: F is a fence place and S is the correspongind switch
  * 
  * @author Gustavo
  */

public class fence_switch extends DefaultInternalAction {

    private static final long serialVersionUID = 1L;

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        try {
            CowboyArch arch = (CowboyArch)ts.getUserAgArch();
            LocalWorldModel model = arch.getModel();
            int i,j,posx = 0,posy = 0;
            boolean ind = false;
            for(i=-1;i<=1;i++){
                for(j=-1;j<=1;j++){
                    if(i == 0 && j == 0) continue;
                    posx = (int)((NumberTerm)args[0]).solve()+i;
                    posy = (int)((NumberTerm)args[1]).solve()+j;
                    while(model.hasObject(WorldModel.FENCE,posx,posy)){
//                      ts.getAg().getLogger().info("ooooo cell at"+posx+"x"+posy+"has no switch, but it's a fence");
                        posx+= i;
                        posy+= j;
                    }
                    if(model.hasObject(WorldModel.SWITCH, posx,posy)){
                        ind = true;
                        break;
                        
                    }
                }
                if(ind) break;
            }
            if(ind){
                ts.getAg().getLogger().info("fff Found switch at ("+posx+","+posy+")");
                return un.unifies(args[2], ASSyntax.createNumber(posx)) 
                    && un.unifies(args[3], ASSyntax.createNumber(posy));
            }
        }catch (Throwable e){
            ts.getLogger().log(Level.SEVERE, "fence_switch: (can't find the switch) "+e, e);
        }
        return false;
    }


}

