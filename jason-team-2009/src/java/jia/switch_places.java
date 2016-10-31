package jia;

import static jason.asSyntax.ASSyntax.createNumber;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.logging.Level;

import env.WorldModel;

import arch.CowboyArch;
import arch.LocalWorldModel;

/**
 * Given the switch, determines the two places where an agent should stand in order to open the fence
 * 
 * Use: jia.switch_places(+Sx, +Sy, +Ax, +Ay, -L1x, -L1y, -L2x, -L2y)
 * where: S is a switch, L1 is the place that open the switch near to the agent A and L2 the other place
 *  
 * @author ricardo.hahn
 *
 */

public class switch_places extends DefaultInternalAction {
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        try {
            CowboyArch arch       = (CowboyArch)ts.getUserAgArch();
            LocalWorldModel model = arch.getModel();
            if (model == null)
                return false;
            
            int lx = (int)((NumberTerm)args[0]).solve();
            int ly = (int)((NumberTerm)args[1]).solve();
            
            int agx = (int)((NumberTerm)args[2]).solve();
            int agy = (int)((NumberTerm)args[3]).solve();
            Location agPlace = new Location(agx,agy); // model.getAgPos(arch.getMyId());
            Location place1 = null, place2 = null;
            
            if (model.isHorizontalFence(lx, ly)) {
                place1 = new Location(lx,ly+1);
                place2 = new Location(lx,ly-1);
            } else {
                place1 = new Location(lx+1,ly);
                place2 = new Location(lx-1,ly);
            }
            int distPlace1 = model.pathLength(agPlace,place1,false, arch);
            int distPlace2 = model.pathLength(agPlace,place2,false, arch);
            if (distPlace1 > distPlace2 | model.hasObject(WorldModel.CORRAL, place1)) {
                // near is place2 (swap)
                Location bak = place2;
                place2 = place1;
                place1 = bak;
            }
            return 
                un.unifies(args[4], createNumber(place1.x)) && 
                un.unifies(args[5], createNumber(place1.y)) &&
                un.unifies(args[6], createNumber(place2.x)) && 
                un.unifies(args[7], createNumber(place2.y));
            
            /* old version 
            Location switchPlace = new Location(lx, ly);
            Location[] freeSwitch = new Location[2];
            int[] dist = {-1 , -1};
            
             
            Location[] d = {new Location(0,1), new Location(0,-1), new Location(1,0), new Location(-1,0) };
            
            for(int k =0; k < 4; ++k) {
                Location candidate = new Location(switchPlace.x-d[k].x,switchPlace.y-d[k].y);
                if(model.inGrid(candidate) && model.isFreeOfObstacle(candidate) && !model.hasFence(candidate.x, candidate.y)) {

                    Nodo solution = new Search(model, agPlace, candidate, null,false, false, false, false, true, false, ts.getUserAgArch()).search();

                    if(solution != null) {
                        int length = solution.getProfundidade();
                        ts.getLogger().info("fff candidate "+candidate.x+" "+candidate.y+" length "+length);
                        if(dist[1]<0 || length<dist[1])
                        {
                            dist[1]=length;
                            freeSwitch[1]=candidate;
                            if(dist[0]<0 || dist[1] < dist[0])
                            {
                                dist[1]=dist[0];
                                dist[0]=length;
                                freeSwitch[1]=freeSwitch[0];
                                freeSwitch[0]=candidate;
                            }
                        }
                    }
                    
                }
                
            }
            if(dist[1]>=0)
                return 
                    un.unifies(args[2], new NumberTermImpl(freeSwitch[0].x)) && 
                    un.unifies(args[3], new NumberTermImpl(freeSwitch[0].y)) &&
                    un.unifies(args[4], new NumberTermImpl(freeSwitch[1].x)) && 
                    un.unifies(args[5], new NumberTermImpl(freeSwitch[1].y));
                    */
        } catch (Throwable e) {
            ts.getLogger().log(Level.SEVERE, "switch_places error: "+e, e);         
        }
        return false;
    }
}

