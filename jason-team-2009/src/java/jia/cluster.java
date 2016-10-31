package jia;

import static jason.asSyntax.ASSyntax.createNumber;
import static jason.asSyntax.ASSyntax.createStructure;
import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.ObjectTermImpl;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import arch.CowboyArch;
import arch.LocalWorldModel;

/** 
 * Computes a cluster of cows for the agent
 * 
 * @author jomi
 */
public class cluster extends DefaultInternalAction {
    
    public static final int COWS_BY_BOY    = 6;
    public static final int MAXCLUSTERSIZE = (7*COWS_BY_BOY)-2; // a size where 7 agents is enough
    
    static Logger logger = null;
    
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        if (logger == null) logger = ts.getLogger();
        
        try {
            CowboyArch arch = (CowboyArch)ts.getUserAgArch();
            LocalWorldModel model = arch.getModel();
            if (model == null)
                return false;

            List<Location> locs = getCluster(model, 3, arch); 
            
            if (args.length == 1) {
                return un.unifies(args[0], new ObjectTermImpl(locs));               
            } else {
                Structure nearCow = null;
                ListTerm r = new ListTermImpl();
                ListTerm tail = r;
                for (Location l: locs) {
                    Structure pos = createStructure("pos", createNumber(l.x), createNumber(l.y));
                    tail = tail.append(pos);
                    if (nearCow == null) // the first location is of the near cow
                        nearCow = pos;
                }
                if (args.length > 2 && nearCow != null)
                    un.unifies(args[2], nearCow);
                return un.unifies(args[0], new ObjectTermImpl(locs)) && 
                       un.unifies(args[1], r);               
            }
        } catch (Throwable e) {
            logger.log(Level.SEVERE, "cluster error: "+e, e);           
        }
        return false;
    }
    
    public static List<Location> getCluster(LocalWorldModel model, int maxDist, CowboyArch arch) throws Exception {
        /*
            Vs = set of all seen cows
            Cs  = { the cow near to the corral }

            add = true
            while (add)
                add = false
                for all v in Vs
                    if (some cow in Cs sees v)
                        move v from Vs to Cs
                        add = true
        */
        Collection<Vec> cows = model.getKnownCows();
        List<Vec> vs = new ArrayList<Vec>();
        
        Location center = model.getCorral().center();
        
        // find cow near corral
        Vec near = null;
        int nearDist = 0;
        for (Vec v: cows) {
            Location cl = v.getLocation(model);
            if (! model.getCorral().contains( cl )) { // add only cows outside corral
                vs.add(v);
                
                // use A* to get the distance from this cow to corral
                int dist = model.pathLength(cl, center, false, arch);
                if (dist >= 0) {
                    if (near == null || dist < nearDist) {
                        near = v;
                        nearDist = dist;
                    }
                }
                /*
                Nodo solution = new Search(model, cl, center, arch).search();
                if (solution != null) {
                    int d = solution.getProfundidade();
                    if (near == null || d < nearDist) {
                        near = v;
                        nearDist = d;
                    }
                }
                */
            }
        }
        
        List<Vec> cs = new ArrayList<Vec>();
        if (near != null) {
            vs.remove(near);
            cs.add(near);
        } else {
            logger.info("ooo There is no near cow in set "+model.getKnownCows());
        }
        
        boolean add = true;
        while (add) {
            add = false;
            Iterator<Vec> i = vs.iterator();
            while (i.hasNext()) {
                Vec v = i.next();
                
                Iterator<Vec> j = cs.iterator();
                while (j.hasNext() && cs.size() < MAXCLUSTERSIZE) {
                    Vec c = j.next();
                    if (c.sub(v).magnitude() < maxDist) {
                        cs.add(v);
                        i.remove();
                        add = true;
                        break;
                    }
                }
            }
            
            // do not get too big clusters
            if (cs.size() > MAXCLUSTERSIZE)
                break;
        }
        List<Location> clusterLocs = new ArrayList<Location>();
        for (Vec v: cs) {
            // place all cows in ref to 0,0
            clusterLocs.add(v.getLocation(model));
        }
        return clusterLocs;
    }
    
    
    public static List<Location> getCluster2008(LocalWorldModel model, int maxDist, CowboyArch arch) throws Exception {
        /*
        Vs = set of all seen cows (sorted by distance to the centre of cluster)
        Cs  = { the cow near to the center of Vs }

        add = true
        while (add)
                add = false
                for all v in Vs
                if (some cow in Cs sees v)
                    move v from Vs to Cs
                    add = true
        */
        Collection<Vec> cows = model.getKnownCows();
        System.out.println(cows);
        List<Vec> cs = new ArrayList<Vec>();
        Vec mean = Vec.mean( cows );

        List<Vec> vs = new ArrayList<Vec>();

        // place all cows in ref to mean
        for (Vec v: cows) {
            Location cl = v.getLocation(model);
            if (! model.getCorral().contains( cl )) { // add only cows outside corral
                Vec vc = v.sub(mean);
                vs.add(vc);
            } else {
                System.out.println("ignoring cow "+v+" because it is inside corral.");
            }
        }
        
        if (vs.size() > 4)
            Collections.sort(vs); // sort only big clusters (for small clusters, to sort causes a kind of oscillation)
        
        if (!vs.isEmpty()) 
            cs.add(vs.remove(0));
        
        boolean add = true;
        while (add) {
            add = false;
            Iterator<Vec> i = vs.iterator(); // candidates cows
            while (i.hasNext()) {
                Vec v = i.next();
                
                Iterator<Vec> j = cs.iterator(); // current cows
                while (j.hasNext() && cs.size() < MAXCLUSTERSIZE) {
                    Vec c = j.next();
                    if (c.sub(v).magnitude() < maxDist) {
                        cs.add(v);
                        i.remove();
                        add = true;
                        break;
                    }
                }
            }
            
            // do not get too big clusters
            if (cs.size() > MAXCLUSTERSIZE)
                break;
        }
        List<Location> clusterLocs = new ArrayList<Location>();
        for (Vec v: cs) {
            // place all cows in ref to 0,0
            clusterLocs.add(v.add(mean).getLocation(model));
        }
        return clusterLocs;
    }

    public static List<Vec> location2vec(LocalWorldModel model, List<Location> clusterLocs) {
        List<Vec> cows = new ArrayList<Vec>();
        for (Location l: clusterLocs) 
            cows.add( new Vec(model, l));
        return cows;
    }
}
