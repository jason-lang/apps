package jia;

import jason.architecture.AgArch;
import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;

import arch.LocalWorldModel;
import busca.AEstrela;
import busca.Busca;
import busca.Estado;
import busca.Heuristica;
import busca.Nodo;
import env.WorldModel;

public class Search {

    public static final  int DIST_FOR_AG_OBSTACLE = 2; // the distance when an agent is considered as obstacle
    
    final LocalWorldModel model;
    final Location        from, to;
    final boolean         considerAgentsAsObstacles;
    final boolean         considerCorralAsObstacles;
    final boolean         considerCowsAsObstacles;
    final boolean         considerRepulsionForCows;
    final boolean         considerEnemyCorralRepulsion;
    final boolean         considerFenceAsObstacle;
    int maxDistFromCluster;
    
    WorldModel.Move[]     actionsOrder;    
    int                   nbStates = 0;
    AgArch                agArch;
    
    public static final WorldModel.Move[] defaultActions = {  // initial order of actions
              WorldModel.Move.west,
              WorldModel.Move.east,
              WorldModel.Move.north,
              WorldModel.Move.northeast,
              WorldModel.Move.northwest,
              WorldModel.Move.south,
              WorldModel.Move.southeast,
              WorldModel.Move.southwest
    }; 

    Logger logger = Logger.getLogger(Search.class.getName());
    
    public Search(LocalWorldModel m, Location from, Location to, WorldModel.Move[] actions, 
                  boolean considerAgentsAsObstacles, 
                  boolean considerCorralAsObstacles, 
                  boolean considerCowsAsObstacles, 
                  boolean considerRepulsionForCows,
                  boolean considerEnemyCorralRepulsion,
                  boolean considerFenceAsObstacle,
                  AgArch agArch) {
        
        this.model = m;
        this.from  = from;
        this.to    = to;
        this.considerAgentsAsObstacles = considerAgentsAsObstacles;
        this.considerCorralAsObstacles = considerCorralAsObstacles;
        this.considerCowsAsObstacles   = considerCowsAsObstacles;
        this.considerRepulsionForCows  = considerRepulsionForCows;
        this.considerEnemyCorralRepulsion = considerEnemyCorralRepulsion;
        this.considerFenceAsObstacle      = considerFenceAsObstacle;
        this.agArch = agArch;
        if (actions != null)
            this.actionsOrder = actions;
        else
            this.actionsOrder = defaultActions;
        
        this.maxDistFromCluster = 4;
        this.nbStates = 0;
        model.getKnownCows(); // to update the cows in model.
    }
    
    public void setMaxDistFromCluster(int m) {
        maxDistFromCluster = m;
    }

    /** used normally to discover the distance from 'from' to 'to' (or if there is path to) */
    Search(LocalWorldModel m, Location from, Location to, AgArch agArch) {
        this(m,from,to,null,false, false, false, false, false, false, agArch);
    }
    
    public Nodo search() throws Exception { 
        Busca searchAlg = new AEstrela();
        //searchAlg.ssetMaxAbertos(1000);
        GridState root = new GridState(from, WorldModel.Move.skip, this);
        root.setAsRoot();
        return searchAlg.busca(root);
    }
    
    public static List<Nodo> normalPath(Nodo n) {
        List<Nodo> r = new LinkedList<Nodo>();
        while (n != null) {
            r.add(0,n);
            n = n.getPai();
        }
        return r;
    }
    
    public static Location getNodeLocation(Nodo n) {
        return ((GridState)n.getEstado()).pos;
    }
    
    public static WorldModel.Move firstAction(Nodo solution) {
        Nodo root = solution;
        Estado prev1 = null;
        Estado prev2 = null;
        while (root != null) {
            prev2 = prev1;
            prev1 = root.getEstado();
            root = root.getPai();
        }
        if (prev2 != null) {
            return ((GridState)prev2).op;
        }
        return null;
    }

    // test
    /*
    public static  void main(String[] a) throws Exception {
        System.out.println("init");
        Location pos = new Location(2,2);
        
        Search ia = new Search(WorldFactory.world9(), pos, new Location(40,40));

        List<GridState> options = new ArrayList<GridState>(4);
        options.add(new GridState(new Location(pos.x,pos.y+1),"down", ia));
        options.add(new GridState(new Location(pos.x-1,pos.y), "left", ia));
        options.add(new GridState(new Location(pos.x,pos.y-1),"up", ia));
        options.add(new GridState(new Location(pos.x+1,pos.y),"right", ia));
        //ia.model.incVisited(options.get(0).pos);
        ia.model.incVisited(options.get(3).pos);
        ia.model.incVisited(options.get(2).pos);
        ia.model.incVisited(options.get(2).pos);
        ia.model.incVisited(options.get(1).pos);
        ia.model.incVisited(options.get(1).pos);
        System.out.println(options);
        for (GridState l: options) {
            System.out.println(l+"="+ia.model.getVisited(l.pos));
        }
        Collections.sort(options, new VisitedComparator(ia.model));
        System.out.println(options);

        Nodo solution = ia.search();
        System.out.println("action = "+ia.firstAction(solution) + ", path size = "+ solution.getProfundidade());
        //System.out.println(solution.montaCaminho());
    }
    */
}


final class GridState implements Estado, Heuristica {

    // State information
    final Location        pos; // current location
    final WorldModel.Move op;
    final Search          ia;
    final int             hashCode;
    boolean               isRoot = false;
    
    public GridState(Location l, WorldModel.Move op, Search ia) {
        this.pos  = l;
        this.op   = op;
        this.ia   = ia;
        hashCode  = pos.hashCode();
        
        ia.nbStates++;
    }
    
    public void setAsRoot() {
        isRoot = true;
    }
    
    public int custo() {
        if (isRoot)
            return 0;
        
        int c = 1;
        
        if (ia.considerCowsAsObstacles) 
            c += ia.model.getCowsRep(pos.x, pos.y);

        if (ia.considerRepulsionForCows) {
            // consider the cost of agents only if they are near
            c +=  ia.model.getObsRep(pos.x, pos.y);
            //if (ia.from.maxBorder(pos) <= ia.maxDistFromCluster) 
            //    c += ia.model.getAgsRep(pos.x, pos.y);
        }
        
        if (ia.considerEnemyCorralRepulsion)
            c +=  ia.model.getEnemyCorralRep(pos.x, pos.y);

        // add cost of fences
        if (ia.model.hasObject(WorldModel.FENCE, pos.x, pos.y))
            c += 5;
        
        return c;
    }

    public boolean ehMeta() {
        return pos.equals(ia.to);
    }

    public String getDescricao() {
        return "Grid search";
    }

    public int h() {
        return pos.distanceChebyshev(ia.to);
    }
    
    public List<Estado> sucessores() {
        List<Estado> s = new ArrayList<Estado>();
        if (ia.nbStates > 100000) {
            ia.logger.info("*** It seems I am in a loop!");
            return s; 
        } else if (ia.agArch != null && !ia.agArch.isRunning()) {
            return s;
        }
                
        // all directions
        for (int a = 0; a < ia.actionsOrder.length; a++) {
            suc(s, WorldModel.getNewLocationForAction(pos, ia.actionsOrder[a]), ia.actionsOrder[a]);
        }
        
        // if it is root state, sort the option by least visited
        if (isRoot) {
            Collections.sort(s, new VisitedComparator(ia.model));
        }
        return s;
    }

    private void suc(List<Estado> s, Location newl, WorldModel.Move op) {

        if (!ia.model.inGrid(newl))
            return;
        if (ia.model.hasObject(WorldModel.OBSTACLE, newl)) 
            return;
        if (ia.considerCorralAsObstacles && ia.model.hasObject(WorldModel.CORRAL, newl)) 
            return;
        if (ia.considerAgentsAsObstacles) {
            if (ia.model.hasObject(WorldModel.AGENT,newl) && ia.from.distanceChebyshev(newl) <= Search.DIST_FOR_AG_OBSTACLE) 
                return;
            if (ia.model.hasObject(WorldModel.ENEMY,newl) && ia.from.distanceChebyshev(newl) <= 1) 
                return;
        }
        if (ia.considerCowsAsObstacles   && ia.model.hasObject(WorldModel.COW,newl)   && ia.from.distanceChebyshev(newl) <= Search.DIST_FOR_AG_OBSTACLE) 
            return;
        if (ia.considerFenceAsObstacle   && ia.model.hasObject(WorldModel.FENCE, newl.x, newl.y)) 
            return;

        s.add(new GridState(newl,op,ia));
    }
        
    public boolean equals(Object o) {
        if (o != null && o instanceof GridState) {
            GridState m = (GridState)o;
            return pos.equals(m.pos);
        }
        return false;
    }
    
    public int hashCode() {
        return hashCode;
    }
            
    public String toString() {
        return "(" + pos + "-" + op + ")"; 
    }
}

class VisitedComparator implements Comparator<Estado> {

    LocalWorldModel model;
    VisitedComparator(LocalWorldModel m) {
        model = m;
    }
    
    public int compare(Estado o1, Estado o2) {
        int v1 = model.getVisited(((GridState)o1).pos);
        int v2 = model.getVisited(((GridState)o2).pos);
        if (v1 > v2) return 1;
        if (v2 > v1) return -1;
        return 0;
    }

}
