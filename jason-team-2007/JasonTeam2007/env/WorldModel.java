package env;

import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;

import java.util.Random;
import java.util.logging.Logger;


/**
 * Class used to model the scenario (either by an global or local view)
 * 
 * @author jomi
 */
public class WorldModel extends GridWorldModel {

    public static final int   GOLD  = 16;
    public static final int   DEPOT = 32;
    public static final int   ENEMY = 64;
    public static final int   TARGET = 128; // one agent target location

    public static final int   AG_CAPACITY = 3; // how many golds an agent can carry

    
    double                    PSim = 0.1; // probability of action/information failure
    double                    PMax = 0.5; // maximal value for action/information failure
    
    Location                  depot;
    int[]                     goldsWithAg;  // how many golds each agent is carrying

    int                       goldsInDepot   = 0;
    int 					  initialNbGolds = 0;
    
    int[][]                   visited; // count the visited locations
    int                       minVisited = 0; // min value for near least visited
    
    int	                      steps = 0; // number of steps of the simulation
    
    private Logger            logger   = Logger.getLogger("jasonTeamSimLocal.mas2j." + WorldModel.class.getName());

    private Random			  random = new Random();

    public enum Move {
        UP, DOWN, RIGHT, LEFT
    };


    public static WorldModel create(int w, int h, int nbAg) {
    	return new WorldModel(w,h,nbAg);
    }
    
    public WorldModel(int w, int h) {
        this(w, h, 6);
    }
    
    public WorldModel(int w, int h, int nbAg) {
        super(w, h, nbAg);
        
        goldsWithAg = new int[nbAg];
        for (int i=0; i< goldsWithAg.length; i++) goldsWithAg[i] = 0;
        
        visited = new int[getWidth()][getHeight()];
        for (int i = 0; i < getWidth(); i++) {
            for (int j = 0; j < getHeight(); j++) {
            	visited[i][j] = 0;
            }
        }
    }

    @Override 
    public boolean isFree(int x, int y) {
        return super.isFree(x,y) && !hasObject(ENEMY, x, y);
    }

    public WorldView getView() {
    	return (WorldView)view;
    }
    
    public void setDepot(int x, int y) {
    	if (depot != null) {
    		data[depot.x][depot.y]    = CLEAN;
            visited[depot.x][depot.y] = 0;
    	}
        depot = new Location(x, y);
        data[x][y] = DEPOT;
        visited[x][y] = 10000;
    }
    

    public Location getDepot() {
        return depot;
    }
    
    public int getGoldsInDepot() {
    	return goldsInDepot;
    }
    
    public boolean hasGold() {
    	return countObjects(GOLD) > 0;
    }
    
    public boolean isAllGoldsCollected() {
    	return goldsInDepot == initialNbGolds;
    }
    
    public void setInitialNbGolds(int i) {
    	initialNbGolds = i;
    }
    
    public int getInitialNbGolds() {
    	return initialNbGolds;
    }

    public boolean isCarryingGold(int ag) {
    	return goldsWithAg[ag] > 0;
    }

    public boolean mayCarryMoreGold(int ag) {
        return goldsWithAg[ag] < AG_CAPACITY;
    }
    
    public int getGoldsWithAg(int ag) {
    	return goldsWithAg[ag];
    }
    public void setGoldsWithAg(int ag, int n) {
    	goldsWithAg[ag] = n;
    }
    
    public void setPSim(double psim) {
        PSim = psim;
    }
    public void setPMax(double pmax) {
        PMax = pmax;
    }
    
    /** returns the probability of action/perception failure for an agent
        based on the number of golds it is carrying 
    */ 
    public double getAgFatigue(int ag) {
        return getAgFatigue(ag, goldsWithAg[ag]); 
    }
    
    public double getAgFatigue(int ag, int golds) {
        return PSim + ((PMax - PSim)/AG_CAPACITY) * golds; 
    }
    
    public void setSteps(int s) {
    	steps = s;
    }
    public int getSteps() {
    	return steps;
    }
        
    public int getVisited(Location l) {
    	return visited[l.x][l.y];
    }

    public void incVisited(Location l) {
    	incVisited(l.x,l.y);
    }
    public void incVisited(int x, int y) {
    	visited[x][y] += 2;
    	
    	if (x > 0) visited[x-1][y]++;
    	if (y > 0) visited[x][y-1]++;
    	if (y > 0 && x > 0) visited[x-1][y-1]++;
    	if (y+1 < getHeight()) visited[x][y+1]++;
    	if (x > 0 && y+1 < getHeight()) visited[x-1][y+1]++;
    	if (x+1 < getWidth()) visited[x+1][y]++;
    	if (x+1 < getWidth() && y > 0) visited[x+1][y-1]++;
    	if (x+1 < getWidth() && y+1 < getHeight()) visited[x+1][y+1]++;
    }
    
    /** returns the near location of x,y that was least visited */
    public Location getNearLeastVisited(int agx, int agy) {
    	//int distanceToBorder = (agx < getWidth()/2 ? agx : getWidth() - agx) - 1; 
    	Location agloc = new Location(agx,agy);
    	
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
    	
    	//int visitedTarget = 0;
    	while (true) {

        	int x = agx;
        	int y = agy;
    		int w = 1; 
        	int dx = 0;
        	int dy = 0;
        	int stage = 1;//(x % 2 == 0 ? 1 : 2);
        	Location better = null;
        	
	    	while (w < getWidth()) { //( (w/2+distanceToBorder) < getWidth()) {
	    		switch (stage) {
	    			case 1: if (dx < w) {
	    				    	dx++;
	    				    	break;
	    					} else {
	    						stage = 2;//(x % 2 == 0) ? 2 : 3; 
	    					}
	    			case 2: if (dy < w) {
	    						dy++;
	    						break;
	    					} else {
	    						stage = 3;//(x % 2 == 0) ? 3 : 1;
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
	    		if (isFree(l) && !l.equals(agloc)) {
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
    }
    
    //public static void main(String[] a) {
    //	WorldModel m = new WorldModel(10,10);
    //	System.out.println(m.getNearLeastVisited(5, 5));
    //}
    
    /** Actions **/

    synchronized public boolean move(Move dir, int ag) throws Exception {
        if (ag < 0) {
            logger.warning("** Trying to move unknown agent!");
            return false;
        }
        Location l = getAgPos(ag);
        if (l == null) {
            logger.warning("** We lost the location of agent " + (ag + 1) + "!"+this);
            return false;
        }
        Location n = null;
        switch (dir) {
        case UP:    n =  new Location(l.x, l.y - 1); break;
        case DOWN:  n =  new Location(l.x, l.y + 1); break;
        case RIGHT: n =  new Location(l.x + 1, l.y); break;
        case LEFT:  n =  new Location(l.x - 1, l.y); break;
        }
        if (n != null && canMoveTo(ag, n)) {
            // if there is an agent there, move that agent
            if (!hasObject(AGENT, n) || move(dir,getAgAtPos(n))) {
                setAgPos(ag, n);
                return true;
            }
        }
        return false;
    }

    private boolean canMoveTo(int ag, Location l) {
    	if (isFreeOfObstacle(l)) {
    		if (!l.equals(getDepot()) || isCarryingGold(ag)) { // if depot, the must be carrying gold
    			return true;
    		}
    	}
    	return false;
    }
    
    public boolean pick(int ag) {
        Location l = getAgPos(ag);
        if (hasObject(WorldModel.GOLD, l.x, l.y)) {
            if (getGoldsWithAg(ag) < AG_CAPACITY) {
                remove(WorldModel.GOLD, l.x, l.y);
                goldsWithAg[ag]++;
                return true;
            } else {
                logger.warning("Agent " + (ag + 1) + " is trying the pick gold, but it is already carrying "+(AG_CAPACITY)+" golds!");
            }
        } else {
            logger.warning("Agent " + (ag + 1) + " is trying the pick gold, but there is no gold at " + l.x + "x" + l.y + "!");
        }
        return false;
    }

    public boolean drop(int ag) {
        Location l = getAgPos(ag);
        if (isCarryingGold(ag)) {
            if (l.equals(getDepot())) {
                logger.info("Agent miner" + (ag + 1) + " carried "+goldsWithAg[ag]+" golds to depot!");
                goldsInDepot += goldsWithAg[ag];
                goldsWithAg[ag] = 0;
            } else {
                add(WorldModel.GOLD, l.x, l.y);
                goldsWithAg[ag]--;
            }
            return true;
        }
        return false;
    }

    /** removes enemies/gold around l */
    public void clearAgView(Location l) {
    	clearAgView(l.x, l.y);
    }

    /** removes enemies/gold around x,y */
    public void clearAgView(int x, int y) {
        int e1 = ~(ENEMY + GOLD);
        
        // nw
        if (x > 0 && y > 0) {
            data[x - 1][y - 1] &= e1;
            if (view != null) view.update(x-1,y-1);
        } 
        // n
        if (y > 0) {
            data[x][y - 1] &= e1;
            if (view != null) view.update(x,y-1);
        } 
        // ne
        if (x < (getWidth() - 1) && y > 0) {
            data[x + 1][y - 1] &= e1;
            if (view != null) view.update(x+1,y-1);
        } 
        // w
        if (x > 0) {
            data[x - 1][y] &= e1;
            if (view != null) view.update(x-1,y);
        } 
        // cur
        data[x][y] &= e1;
        
        // e
        if (x < (getWidth() - 1)) {
            data[x + 1][y] &= e1;
            if (view != null) view.update(x+1,y);
        } 
        // sw
        if (x > 0 && y < (getHeight() - 1)) {
            data[x - 1][y + 1] &= e1;
            if (view != null) view.update(x-1,y+1);
        } 
        // s
        if (y < (getHeight() - 1)) {
            data[x][y + 1] &= e1;
            if (view != null) view.update(x,y+1);
        } 
        // se
        if (x < (getWidth() - 1) && y < (getHeight() - 1)) {
            data[x + 1][y + 1] &= e1;
            if (view != null) view.update(x+1,y+1);
        }
    }

    public void wall(int x1, int y1, int x2, int y2) {
    	for (int i=x1; i<=x2; i++) {
    		for (int j=y1; j<=y2; j++) {
    			data[i][j] = OBSTACLE;
    		}
    	}
    }
    
    public String toString() {
    	StringBuilder s = new StringBuilder();

    	s.append("---------------------------------------------\n|");
    	for (int j = 0; j < getHeight(); j++) {
    		for (int i = 0; i < getWidth(); i++) {
            	if (hasObject(OBSTACLE, i, j)) {
            		s.append('X');
            	} else if (hasObject(DEPOT, i, j)) {
            		s.append('O');
            	} else if (hasObject(AGENT, i, j)) {
            		s.append((getAgAtPos(i, j)+1)+"");
            	} else if (hasObject(GOLD, i, j)) {
            		s.append('G');
            	} else if (hasObject(ENEMY, i, j)) {
            		s.append('E');
            	} else {
            		s.append(' ');
            	}
            }
            s.append("|\n|");
        }
    	s.append("---------------------------------------------\n");
    	
    	return s.toString();
    }
}
