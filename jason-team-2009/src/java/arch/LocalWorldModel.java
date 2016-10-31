package arch;

import static jason.asSyntax.ASSyntax.createLiteral;
import static jason.asSyntax.ASSyntax.createNumber;
import jason.architecture.AgArch;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.bb.BeliefBase;
import jason.environment.grid.Location;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import jia.Search;
import jia.Vec;
import moise.simple.oe.Pair;
import busca.Nodo;
import env.WorldModel;


/**
 * Class used to model the scenario (for an agent view)
 * 
 * @author jomi
 */
public class LocalWorldModel extends WorldModel {

    int[][]         visited; // count the visited locations
    int             minVisited = 0; // min value for near least visited
    
    private Random  random = new Random();

    Set<Vec>        knownCows = new HashSet<Vec>();

    boolean         isKnownCowsUptodate = false;
    
    int[][]         cowsrep; // cows repulsion 
    //int[][]         agsrep;  // agents repulsion
    int[][]         obsrep;  // obstacle repulsion
    int[][]         enemycorralrep; // repulsion from enemy corral

    // store distance between locations
    Map< Pair<Location, Location>, Integer> dist = new HashMap<Pair<Location,Location>, Integer>();
    boolean distOutdated = true;
    
    BeliefBase      bb; // agent's BB
    
    //private Logger            logger   = Logger.getLogger("jasonTeamSimLocal.mas2j." + LocalWorldModel.class.getName());

    public LocalWorldModel(int w, int h, int nbAg, BeliefBase bb) {
        super(w, h, nbAg);
        this.bb = bb;
        
        visited = new int[getWidth()][getHeight()];
        for (int i = 0; i < getWidth(); i++)
            for (int j = 0; j < getHeight(); j++)
                visited[i][j] = 0;

        cowsrep         = new int[getWidth()][getHeight()];
        
        //agsrep          = new int[getWidth()][getHeight()];
        obsrep          = new int[getWidth()][getHeight()];
        enemycorralrep  = new int[getWidth()][getHeight()];
        for (int i = 0; i < getWidth(); i++)
            for (int j = 0; j < getHeight(); j++) {
                //agsrep[i][j] = 0;
                obsrep[i][j] = 0;
                enemycorralrep[i][j] = 0;
            }
    }
    
    @Override
    public void add(int value, int x, int y) {
        //if (value == WorldModel.AGENT || value == WorldModel.ENEMY) {
        switch (value) {
        //case ENEMY:        increp(agsrep, x, y, 2, 2); break;
        case OBSTACLE:     increp(obsrep, x, y, 1, 1);
                           distOutdated = true;
                           break;
        case ENEMYCORRAL:  increp(enemycorralrep, x, y, 1, 2); 
                           add(OBSTACLE, x, y);
                           break;
        case OPEN_FENCE:   if (hasObject(CLOSED_FENCE, x, y)) // change state
                               remove(CLOSED_FENCE, x, y);
                           break;
        case CLOSED_FENCE: if (hasObject(OPEN_FENCE, x, y))  // change state
                               remove(OPEN_FENCE, x, y);
                           break;
        case SWITCH:       // the fence besides is an obstacle
                           if (hasObject(FENCE, x+1,y)) add(OBSTACLE, x+1,y);
                           if (hasObject(FENCE, x-1,y)) add(OBSTACLE, x-1,y);
                           if (hasObject(FENCE, x,y+1)) add(OBSTACLE, x,y+1);
                           if (hasObject(FENCE, x,y-1)) add(OBSTACLE, x,y-1);
                           add(OBSTACLE, x, y); // switch is obstacle
                           break;
        }   
        super.add(value, x, y);
    }
    
    public boolean isHorizontalFence(int x, int y) {
        return hasObject(WorldModel.FENCE, x+1, y) || hasObject(WorldModel.FENCE, x-1, y);
    }
    
    /*
    @Override
    public void remove(int value, int x, int y) {
        super.remove(value, x, y);
        //if (value == WorldModel.AGENT || value == WorldModel.ENEMY) {
        if (value == WorldModel.ENEMY) {
            increp(agsrep, x, y, 2, -2);
        }
    }
    */
    
    // cows methods
    
    public void clearKnownCows() {
        isKnownCowsUptodate = false;
    }
    
    public Set<Vec> getKnownCows() {
        synchronized (knownCows) {
            if (!isKnownCowsUptodate)
                updateCowsFromBB();
            return new HashSet<Vec>(knownCows);
        }
    }

    private static final Literal cowLiteral = Literal.parseLiteral("cow(Id,X,Y)");
    
    /** search for cows in the BB and populates the world model with them */
    private void updateCowsFromBB() {
        if (bb == null) return;
        
        synchronized (knownCows) {
                
            // clean
            removeAll(WorldModel.COW);
    
            for (int i = 0; i < getWidth(); i++)
                for (int j = 0; j < getHeight(); j++)
                    cowsrep[i][j] = 0;
            
            knownCows.clear();
    
            // rebuild
            Iterator<Literal> i = bb.getCandidateBeliefs(cowLiteral, null);
            if (i != null) {
                while (i.hasNext()) {
                    Literal c = i.next();
                    int x = (int)((NumberTerm)c.getTerm(1)).solve();
                    int y = (int)((NumberTerm)c.getTerm(2)).solve();
                    addKnownCow(x,y);
                }
            }
            isKnownCowsUptodate = true;
        }
    }
    
    public void addKnownCow(int x, int y) {
        add(WorldModel.COW, x, y);
        knownCows.add(new Vec( this, x, y));        
        increp(cowsrep, x, y, 2, 1);
    }
    

    public int getCowsRep(int x, int y) {
        return cowsrep[x][y];
    }
    /*
    public int getAgsRep(int x, int y) {
        return agsrep[x][y];
    }
    */
    public int getObsRep(int x, int y) {
        return obsrep[x][y];
    }
    public int getEnemyCorralRep(int x, int y) {
        return enemycorralrep[x][y];
    }

    private void increp(int[][] m, int x, int y, int ratio, int value) {
        for (int r = 1; r <= ratio; r++)
            for (int c = x-r; c <= x+r; c++)
                for (int l = y-r; l <= y+r; l++)
                    if (inGrid(c,l)) {
                        m[c][l] += value;
                    }
    }

    // occupied means the places that can not be considered as nearFree
    public Location nearFree(Location l, List<Location> occupied) throws Exception {
        int w = 0;
        Location newl;
        if (occupied == null) occupied = Collections.emptyList(); 
        //List<Location> options = new ArrayList<Location>();
        while (true) {
            //options.clear();
            for (int y=l.y-w+1; y<l.y+w; y++) {
                //System.out.println(" "+(l.x+w)+" "+y);
                //System.out.println(" "+(l.x-w)+" "+y);
                newl = new Location(l.x-w,y);
                if (isFree(newl) && !occupied.contains(newl)) 
                    //options.add(newl);
                    return newl;
                newl = new Location(l.x+w,y);
                if (isFree(newl) && !occupied.contains(newl)) 
                    //options.add(newl);
                    return newl;
            }
            for (int x=l.x-w; x<=l.x+w;x++) {
                newl = new Location(x,l.y-w);
                if (isFree(newl) && !occupied.contains(newl)) 
                    //options.add(newl);
                    return newl;
                newl = new Location(x,l.y+w);
                if (isFree(newl) && !occupied.contains(newl)) 
                    //options.add(newl);
                    return newl;
            }
            //if (!options.isEmpty()) 
            //  return options.get(random.nextInt(options.size()));
            w++;
        }
    }
    
    public Set<Location> getAllObj(int obj) {
        Set<Location> all = new HashSet<Location>();
        for (int i = 0; i < getWidth(); i++)
            for (int j = 0; j < getHeight(); j++)
                if (hasObject(obj, i, j))
                    all.add(new Location(i,j));
        return all;
    }
    
    public int countObjInArea(int obj, Location startPoint, int size) {
        int c = 0;
        for (int x = startPoint.x-size; x <= startPoint.x+size; x++) {
            for (int y = startPoint.y-size; y <= startPoint.y+size; y++) {
                if (hasObject(obj, x, y)) {
                    c++;
                }
            }
        }
        return c;
    }
    
    public int getVisited(Location l) {
        return visited[l.x][l.y];
    }

    public void incVisited(Location l) {
        incVisited(l.x,l.y);
    }

    public void incVisited(int x, int y) {
        visited[x][y] += 2;
        increp(visited, x, y, 4, 1);
        /*
        if (x > 0)                                 visited[x-1][y  ]++;
        if (y > 0)                                 visited[x  ][y-1]++;
        if (y > 0 && x > 0)                        visited[x-1][y-1]++;
        if (y+1 < getHeight())                     visited[x  ][y+1]++;
        if (x > 0 && y+1 < getHeight())            visited[x-1][y+1]++;
        if (x+1 < getWidth())                      visited[x+1][y  ]++;
        if (x+1 < getWidth() && y > 0)             visited[x+1][y-1]++;
        if (x+1 < getWidth() && y+1 < getHeight()) visited[x+1][y+1]++;
        */
    }
    
    /** computes the distance between locations using A* and manages a cache of values */
    public int pathLength(Location start, Location target, boolean fenceAsObstacle, AgArch arch) throws Exception {
        if (distOutdated) {
            synchronized (dist) {
                dist.clear();
                distOutdated = false;
            }
        }
        Pair<Location,Location> pair = new Pair<Location,Location>(start, target);
        Integer iDistance = null;
        if (!fenceAsObstacle) {
            iDistance = dist.get(pair);
            if (iDistance == null) {
                pair = new Pair<Location,Location>(target, start);
                iDistance = dist.get(pair);
            }
            if (iDistance != null) { // if the distance is in the map
                // TEST
                /*
                Nodo solution = new Search(this, start, target, null, false, false, false, false, false, fenceAsObstacle, arch).search();
                if (solution == null) {
                    return -1;
                } else {
                    int distance = solution.getProfundidade();
                    String s = "";
                    if (iDistance.intValue() != distance) 
                        s = "******** xxxxxx *******";
                    arch.getTS().getLogger().info("ggg by s "+distance+" by map "+iDistance+s);
                }
                */
                return iDistance;
            }
        }
        
        // case of fenceAsObs or not found in Map
        Nodo solution = new Search(this, start, target, null, false, false, false, false, false, fenceAsObstacle, arch).search();
        if (solution == null) {
            return -1;
        } else {
            int distance = solution.getProfundidade();
            if (!fenceAsObstacle) {
                synchronized (dist) {
                    dist.put(pair, distance);
                }
            }
            return distance;
        }
    }
    
    /** returns the near location of x,y that was least visited */
    public Location getNearLeastVisited(Location agloc, Location tl, Location br) throws Exception {
        /*
        logger.info("------");
        for (int i = 0; i < getWidth(); i++) {
            String line = "";
            for (int j = 0; j < getHeight(); j++) {
                line += visited[j][i] + " ";
            }
            logger.info(line);
        }
        */
        
        // if the agent is not in the area, goes to the area
        if (! agloc.isInArea(tl, br)) {
            return nearFree(new Location( (tl.x+br.x)/2, (tl.y+br.y)/2), null);
        }
        
        Location better = null;
        
        //int visitedTarget = 0;
        int loopcount = 0;
        while (loopcount < 100) {
            loopcount++;

            int x = agloc.x;
            int y = agloc.y;
            int w = 1; 
            int dx = 0;
            int dy = 0;
            int stage = 1;//(x % 2 == 0 ? 1 : 2);
            better = null;
            while (w < getWidth()) { //( (w/2+distanceToBorder) < getWidth()) {
                
                switch (stage) {
                    case 1: if (dx < w) {
                                dx++;
                                break;
                            } else {
                                stage = 2;
                            }
                    case 2: if (dy < w) {
                                dy++;
                                break;
                            } else {
                                stage = 3;
                            }
                    case 3: if (dx > 0) {
                                dx--;
                                break;
                            } else {
                                stage = 4;
                            }
                    case 4: if (dy > 0) {
                                dy--;
                                break;
                            } else {
                                stage = 1;
                                x--;
                                y--;
                                w += 2;
                            }
                }
                
                Location l = new Location(x+dx,y+dy);
                if (isFree(l) && !l.equals(agloc) && l.isInArea(tl, br) && !hasObject(WorldModel.FENCE, l.x, l.y)) {
                    if (visited[l.x][l.y] < minVisited) { // a place better then minVisited! go there
                        return l;
                    } if (visited[l.x][l.y] == minVisited) { // a place in the minVisited level
                        if (better == null) {
                            better = l;
                        } else if (l.distance(agloc) < better.distance(agloc)) {
                            better = l;
                        } else if (l.distance(agloc) == better.distance(agloc) && random.nextBoolean()) { // to chose ramdomly equal options
                            better = l;
                        }
                    }
                }
            } // end while
            
            if (better != null) {
                return better;
            }
            minVisited++;
        }
        return better;
    }
    

    /** removes enemies/gold around l */
    public void clearAgView(Location l) {
        clearAgView(l.x, l.y);
    }

    private static final int cleanPerception = ~(ENEMY); // + COW);

    /** removes enemies/gold around x,y */
    public void clearAgView(int x, int y) {
        int r = agPerceptionRatio;
        for (int c=x-r; c<=x+r; c++) {
            for (int l=y-r; l<=y+r; l++) {
                if (inGrid(c, l)) {
                    data[c][l] &= cleanPerception;
                    if (view != null) view.update(c,l);                    
                }
            }
        }
    }

    private static final File directory = new File("bak-obs");
    
    /** creates a thread that stores obstacles, fences, switches in a file */
    public void createStoreObsThread(final CowboyArch arch) {
        new Thread("store obs") {
            @Override
            public void run() {
                directory.mkdirs();
                while (true) {
                    try {
                        sleep(10000+random.nextInt(10000));
                        
                        // store obstacles
                        StringBuilder sout = new StringBuilder(); // in a string firstly
                        for (int i = 0; i < getWidth(); i++)
                            for (int j = 0; j < getHeight(); j++) {
                                if (hasObject(WorldModel.OBSTACLE, i, j) && !arch.isEphemeralObstacle(new Location(i,j))) 
                                    sout.append("obstacle("+i+","+j+")\n");
                                if (hasObject(WorldModel.FENCE, i, j)) 
                                    sout.append("fence("+i+","+j+")\n");
                            }
                        
                        // store SWITCH after fences! 
                        for (int i = 0; i < getWidth(); i++)
                            for (int j = 0; j < getHeight(); j++) {
                                if (hasObject(WorldModel.SWITCH, i, j)) 
                                    sout.append("switch("+i+","+j+")\n");
                            }
                        
                        // now put in a file
                        BufferedWriter out = new BufferedWriter(new FileWriter(getObstaclesFileName(arch)));
                        out.write(sout.toString());
                        out.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }.start();
    }
    
    public void restoreObstaclesFromFile(final CowboyArch arch) {
        File f = new File(getObstaclesFileName(arch));
        //arch.logger.info("file "+f+" "+f.exists());
        if (f.exists()) {
            Set<Location> included = new HashSet<Location>();
            try {
                arch.logger.info("Loading obstacles from "+f);
                BufferedReader in = new BufferedReader(new FileReader(f));
                String lin = in.readLine();
                while (lin != null) {
                    Literal obs = ASSyntax.parseLiteral(lin);
                    Location l = new Location((int)((NumberTerm)obs.getTerm(0)).solve(), (int)((NumberTerm)obs.getTerm(1)).solve());
                    if (obs.getFunctor().equals("obstacle")) {
                        add(WorldModel.OBSTACLE, l);
                        included.add(l);
                    } else if (obs.getFunctor().equals("fence")) {
                        add(WorldModel.CLOSED_FENCE, l);
                        included.add(l);
                    } else if (obs.getFunctor().equals("switch")) {
                        add(WorldModel.SWITCH, l);
                        arch.getTS().getAg().addBel(createLiteral("switch", createNumber(l.x), createNumber(l.y)));
                        included.add(l);
                    }
                    lin = in.readLine();
                }
            } catch (ArrayIndexOutOfBoundsException e) { // a location out of world means wrong input file, remove all included obstacles
                for (Location l: included) {
                    remove(WorldModel.OBSTACLE, l);
                    remove(WorldModel.CLOSED_FENCE, l);
                    remove(WorldModel.SWITCH, l);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }            
        }
    }
    @SuppressWarnings("deprecation")
    private String getObstaclesFileName(final CowboyArch arch) {
        return directory + "/" + arch.getAgName()+ "-" + getOpponent() + arch.getSimId() + getMaxSteps() +getCorral() + "-"+ new Date().getDay() + ".bb";
    }
}
