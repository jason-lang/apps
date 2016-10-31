package jia;

import jason.asSemantics.*;
import jason.asSyntax.*;
import jason.environment.grid.Location;
import arch.MinerArch;
import busca.Nodo;
import java.util.logging.*;

import env.WorldModel;

public class path_length extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
        try {
            WorldModel model = ((MinerArch)ts.getUserAgArch()).getModel();
    
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
                
                Nodo solution = new Search(model, from, to).search();
                if (solution != null) {
                    int length = solution.getProfundidade();
                    return un.unifies(terms[4], new NumberTermImpl(length));
                } else {
                    ts.getLogger().info("No route from "+from+" to "+to+"!"+"\n"+model);
                }
            }
        } catch (Throwable e) {
            ts.getLogger().log(Level.SEVERE, "jia.path_length error: "+e, e);
        }
        return false;
    }
}

