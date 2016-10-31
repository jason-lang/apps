package jia;

import static jason.asSyntax.ASSyntax.createNumber;
import static jason.asSyntax.ASSyntax.createStructure;
import jason.JasonException;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.ObjectTerm;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;

import arch.CowboyArch;
import arch.LocalWorldModel;
import busca.Nodo;
import env.WorldModel;

/** 
 * Gives a good location to herd cows
 * 
 * the first argument is the formation id (one, two, ... 1, 2, ....)
 * 
 * the second is the cluster [ pos(X,Y), ..... ] (the term returned by jia.cluster)
 * 
 * if it is called with 3 args, returns in the third arg the formation, a list
 * in the format [pos(X,Y), .....]
 * 
 * if it is called with 4 args, returns the a free location in the formation
 * otherwise (3rd is X and 4th is Y)
 *  
 * @author jomi
 */
public class herd_position extends DefaultInternalAction {
    
    public static final int    agDistanceInFormation = 3;

    public enum Formation { 
        one   { Vec[] getDistances() { return new Vec[] { new Vec(0,0) }; } }, 
        two   { Vec[] getDistances() { return new Vec[] { new Vec(sd+1,0), new Vec(-sd, 0) }; } },
        three { Vec[] getDistances() { return new Vec[] { new Vec(0,0),  new Vec(d, -1), new Vec(-d, -1) }; } },
        four  { Vec[] getDistances() { return new Vec[] { new Vec(sd+1,0), new Vec(-sd, 0), new Vec(d+sd, -3), new Vec(-(d+sd), -3) }; } },
        five  { Vec[] getDistances() { return new Vec[] { new Vec(0,0),  new Vec(d, -1), new Vec(-d, -1),  new Vec(d*2-1,-4), new Vec(-d*2,-4) }; } },
        six   { Vec[] getDistances() { return new Vec[] { new Vec(sd+1,0), new Vec(-sd, 0), new Vec(d+sd, -3), new Vec(-(d+sd), -3), new Vec(d*2+sd-2, -6), new Vec(-(d*2+sd-2), -6) }; } },
        seven { Vec[] getDistances() { return new Vec[] { new Vec(0,0),  new Vec(d, -1), new Vec(-d, -1),  new Vec(d*2-1,-4), new Vec(-d*2,-4), new Vec(d*3-1,-6), new Vec(-d*3,-6) }; } },
        eight { Vec[] getDistances() { return new Vec[] { new Vec(sd+1,0), new Vec(-sd, 0), new Vec(d+sd, -3), new Vec(-(d+sd), -3), new Vec(d*2+sd-2, -6), new Vec(-(d*2+sd-2), -6), new Vec(d*3+sd-2, -8), new Vec(-(d*3+sd-2), -8) }; } },
        nine  { Vec[] getDistances() { return new Vec[] { new Vec(0,0),  new Vec(d, -1), new Vec(-d, -1),  new Vec(d*2-1,-4), new Vec(-d*2,-4), new Vec(d*3-1,-6), new Vec(-d*3,-6), new Vec(d*4-1,-8), new Vec(-d*4,-8) }; } },
        ten   { Vec[] getDistances() { return new Vec[] { new Vec(sd+1,0), new Vec(-sd, 0), new Vec(d+sd, -3), new Vec(-(d+sd), -3), new Vec(d*2+sd-2, -6), new Vec(-(d*2+sd-2), -6), new Vec(d*3+sd-2, -8), new Vec(-(d*3+sd-2), -8), new Vec(d*4+sd-2, -10), new Vec(-(d*4+sd-2), -10) }; } };
        abstract Vec[] getDistances();
        private static final int d  = agDistanceInFormation;
        private static final int sd = agDistanceInFormation/2;
    };
    
    LocalWorldModel model;
    List<Location> lastCluster = null;

    public void setModel(LocalWorldModel model) {
        this.model = model;
    }
    
    @SuppressWarnings("unchecked")
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        try {
            CowboyArch arch       = (CowboyArch)ts.getUserAgArch();
            model = arch.getModel();
            if (model == null)
                return false;
            Location agLoc = model.getAgPos(arch.getMyId());
            if (agLoc == null) {
                ts.getLogger().info("*** I have no location yet, so can not compute herd_position!");
                return false;
            }

            // identify the formation id
            Formation formation = Formation.six;
            if (args[0].isNumeric()) {
                int index = (int)((NumberTerm)args[0]).solve();
                formation = Formation.values()[ index-1 ];
            } else {
                formation = Formation.valueOf(args[0].toString());
            }
            
            // get the cluster
            List<Location> clusterLocs = (List<Location>)((ObjectTerm)args[1]).getObject();
            
            // update GUI
            if (arch.hasGUI())
                setFormationLoc(clusterLocs, formation);

            // if the return is a location for one agent
            if (args.length == 4) {
                Location agTarget = getAgTarget(clusterLocs, formation, agLoc);
                if (agTarget != null) {
                    return un.unifies(args[2], new NumberTermImpl(agTarget.x)) && 
                           un.unifies(args[3], new NumberTermImpl(agTarget.y));
                } else {
                    ts.getLogger().info("No target! I am at "+agLoc+" places are "+formationPlaces(clusterLocs, formation)+" cluster is "+lastCluster);
                }
            } else {
                // return all the locations for the formation
                List<Location> locs = formationPlaces(clusterLocs, formation);
                if (locs != null && locs.size() > 0) {
                    ListTerm r = new ListTermImpl();
                    ListTerm tail = r;
                    for (Location l: locs) {
                        tail = tail.append(createStructure("pos", createNumber(l.x), createNumber(l.y)));
                    }
                    return un.unifies(args[2], r);
                } else {
                    ts.getLogger().info("No possible formation! I am at "+agLoc+" places are "+formationPlaces(clusterLocs, formation));                    
                }
            }
        } catch (Throwable e) {
            ts.getLogger().log(Level.SEVERE, "herd_position error: "+e, e);         
        }
        return false;
    }
    
    public Location getAgTarget(List<Location> clusterLocs, Formation formation, Location ag) throws Exception {
        Location r = null;
        List<Location> locs = formationPlaces(clusterLocs, formation);
        if (locs != null) {
            for (Location l : locs) {
                if (ag.equals(l) || // I am there
                    //model.countObjInArea(WorldModel.AGENT, l, 1) == 0) { // no one else is there
                    !model.hasObject(WorldModel.AGENT, l)) {
                    r = l;
                    break;
                }
            }
        }
        if (r != null)
            r = model.nearFree(r, null);
        return r;
    }

    public void setFormationLoc(List<Location> clusterLocs, Formation formation) throws Exception {
        model.removeAll(WorldModel.FORPLACE);
        List<Location> locs = formationPlaces(clusterLocs, formation);
        if (locs != null) {
            for (Location l : locs) {
                if (model.inGrid(l)) {
                    model.add(WorldModel.FORPLACE, l);
                }
            }
        }
    }
    
    public List<Location> formationPlaces(List<Location> clusterLocs, Formation formation) throws Exception {
        lastCluster = clusterLocs;

        List<Vec> cows = cluster.location2vec(model, clusterLocs);

        if (cows.isEmpty())
            return null;
        
        Vec mean = Vec.mean(cows);
        int stepsFromCenter = Math.max(4, (int)Math.round(Vec.max(cows).sub(mean).magnitude())+1);
        //Vec max = Vec.max(cows);
        
        // run A* to see the cluster target in n steps
        Search s = new Search(model, mean.getLocation(model), model.getCorral().center(), null, false, false, false, false, false, false, null);
        s.setMaxDistFromCluster(stepsFromCenter+Search.DIST_FOR_AG_OBSTACLE);
        List<Nodo> np = Search.normalPath(s.search());
        int n = Math.min(stepsFromCenter, np.size());
        if (n == 0)
            throw new JasonException("**** there is no path for the cluster to the curral!!!! "+clusterLocs+" cows:"+cows);

        Vec cowstarget = new Vec(model, Search.getNodeLocation(np.get(n)));
        // find cow farthest of corral
        Vec farcow = null;
        for (Vec c: cows)
            if (farcow == null || farcow.getLocation(model).distanceChebyshev(model.getCorral().center()) < c.getLocation(model).distanceChebyshev(model.getCorral().center()))
                farcow = c;
        
        //Collection<Vec> allcows = model.getCows();
        Vec agsTarget  = mean.sub(cowstarget).newMagnitude(farcow.sub(mean).magnitude()+1);
        //System.out.println("Ags target = "+agsTarget+" mean = "+mean + " far cow is "+farcow);
        List<Location> r = new ArrayList<Location>();
        for (Vec position: formation.getDistances()) { // 2, -2, 6, -6, ....
            //System.out.println(".......  "+position+" + "+agsTarget+" = " + agTarget);
            Location l = findFirstFreeLocTowardsTarget(agsTarget, position, mean, false, model);
            //System.out.println(" =       "+position+" result  "+l);
            if (l == null) {
                l = model.nearFree(agsTarget.add(mean).getLocation(model), r);              
            } else {
                //if (clusterLocs.size() > 10)
                if (formation == Formation.one || formation == Formation.two)
                    l = pathToNearCow(l, clusterLocs);
                if ( !model.inGrid(l) || model.hasObject(WorldModel.OBSTACLE, l) || r.contains(l))
                    l = model.nearFree(l, r);
            }
            r.add( l );
        }
        //System.out.println("all places "+r);
        return r;
    }
    
    public static Location findFirstFreeLocTowardsTarget(Vec start, Vec direction, Vec ref, boolean fenceAsObs, LocalWorldModel model) {
        Vec startandref = start.add(ref);
        Vec t = start.turn90CW();
        t = t.newAngle(t.angle()+direction.angle());

        //System.out.println(start + " to "+ direction + " = " + end);
        int maxSize = (int)direction.magnitude();
        Location l = t.newMagnitude(maxSize).add(startandref).getLocation(model);
        
        Location lastloc = null;
        for (int s = 1; s <= maxSize; s++) {
            l = t.newMagnitude(s).add(startandref).getLocation(model);
            //System.out.println(" test "+s+" = "+l+" -- ");
            if ( (!model.inGrid(l) || model.hasObject(WorldModel.OBSTACLE, l)  || model.hasObject(WorldModel.CORRAL, l)) && lastloc != null)
                return lastloc;
            if ( fenceAsObs && model.hasObject(WorldModel.FENCE, l) && lastloc != null)
                return lastloc;
            lastloc = l;
        }
        
        return l;
    }
    
    private Location pathToNearCow(Location t, List<Location> cows) {
        Location near = null;
        for (Location c: cows) {
            if (near == null || t.distanceChebyshev(c) < t.distanceChebyshev(near))
                near = c;
        }
        if (near != null && t.distanceChebyshev(near) > WorldModel.cowPerceptionRatio) { // if the agent is far from the near cow
            Vec nearcv = new Vec(model,near);
            Vec dircow = new Vec(model,t).sub(nearcv);
            //System.out.println("Near cow to "+t+" is "+near+" vec = "+dircow);
            for (int s = 1; s <= 3; s++) {
                Location l = dircow.newMagnitude(s).add(nearcv).getLocation(model);
                if (!model.hasObject(WorldModel.COW,l))
                    return l;
            }
        }
        return t;
    }
    
    /*
    public Location nearFreeForAg(LocalWorldModel model, Location ag, Location t) throws Exception {
        // run A* to get the path from ag to t
        if (! model.inGrid(t))
            t = model.nearFree(t);
        
        Search s = new Search(model, ag, t, null, true, true, true, false, null);
        List<Nodo> np = s.normalPath(s.search());
        
        int i = 0;
        ListIterator<Nodo> inp = np.listIterator(np.size());
        while (inp.hasPrevious()) {
            Nodo n = inp.previous();
            if (model.isFree(s.getNodeLocation(n))) {
                return s.getNodeLocation(n);
            }
            if (i++ > 3) // do not go to far from target
                break;
        }
        return model.nearFree(t);
    }
        */
}

