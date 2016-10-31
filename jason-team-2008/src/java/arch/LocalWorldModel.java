package arch;

import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.bb.BeliefBase;
import jason.environment.grid.Location;

import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import java.util.Set;

import jia.Vec;
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

    Set<Vec>        cows = new HashSet<Vec>();
    boolean         isCowsUptodate = false;
    
    int[][]         cowsrep; // cows repulsion 
    int[][]         agsrep;  // agents repulsion
    int[][]         obsrep;  // obstacle repulsion
    int[][]         enemycorralrep; // repulsion from enemy corral
    
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
        
        agsrep          = new int[getWidth()][getHeight()];
        obsrep          = new int[getWidth()][getHeight()];
        enemycorralrep  = new int[getWidth()][getHeight()];
        for (int i = 0; i < getWidth(); i++)
            for (int j = 0; j < getHeight(); j++) {
                agsrep[i][j] = 0;
                obsrep[i][j] = 0;
                enemycorralrep[i][j] = 0;
            }

    }
    
    @Override
    public void add(int value, int x, int y) {
        //if (value == WorldModel.AGENT || value == WorldModel.ENEMY) {
        if (value == WorldModel.ENEMY) {
            increp(agsrep, x, y, 2, 2);
        } else if (value == WorldModel.OBSTACLE) {
            increp(obsrep, x, y, 1, 1);
        } else if (value == WorldModel.ENEMYCORRAL) {
            increp(enemycorralrep, x, y, 3, 3);
            value = OBSTACLE;
        }
        super.add(value, x, y);
    }
    @Override
    public void remove(int value, int x, int y) {
        super.remove(value, x, y);
        //if (value == WorldModel.AGENT || value == WorldModel.ENEMY) {
        if (value == WorldModel.ENEMY) {
            increp(agsrep, x, y, 2, -2);
        }
    }

    // cows methods
    
    public void clearCows() {
        isCowsUptodate = false;
    }
    
    public Set<Vec> getCows() {
        if (!isCowsUptodate)
            updateCowsFromBB();
        return cows;
    }

    private static final Literal cowLiteral = Literal.parseLiteral("cow(Id,X,Y)");
    
    private void updateCowsFromBB() {
        if (bb == null) return;
        
        // clean
        removeAll(WorldModel.COW);

        for (int i = 0; i < getWidth(); i++)
            for (int j = 0; j < getHeight(); j++)
                cowsrep[i][j] = 0;
        
        cows.clear();

        // rebuild
        Iterator<Literal> i = bb.getCandidateBeliefs(cowLiteral, null);
        if (i != null) {
            while (i.hasNext()) {
                Literal c = i.next();
                int x = (int)((NumberTerm)c.getTerm(1)).solve();
                int y = (int)((NumberTerm)c.getTerm(2)).solve();
                addCow(x,y);
            }
        }
        isCowsUptodate = true;
    }
    
    public void addCow(int x, int y) {
        add(WorldModel.COW, x, y);
        cows.add(new Vec( this, x, y));        
        increp(cowsrep, x, y, 3, 1);
    }
    

    public int getCowsRep(int x, int y) {
        return cowsrep[x][y];
    }
    public int getAgsRep(int x, int y) {
        return agsrep[x][y];
    }
    public int getObsRep(int x, int y) {
        return obsrep[x][y];
    }
    public int getEnemyCorralRep(int x, int y) {
        return enemycorralrep[x][y];
    }

    private void increp(int[][] m, int x, int y, int maxr, int value) {
        for (int r = 1; r <= maxr; r++)
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
    
    /** returns the near location of x,y that was least visited */
    public Location getNearLeastVisited(Location agloc, Location tr, Location bl) {
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
                if (isFree(l) && !l.equals(agloc) && l.isInArea(tr, bl)) {
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

    private static final int cleanPerception = ~(ENEMY + COW);

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

}
