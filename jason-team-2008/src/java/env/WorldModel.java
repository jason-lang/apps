package env;

import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;

import java.util.logging.Logger;


/**
 * Class used to model the scenario
 * 
 * @author Jomi
 */
public class WorldModel extends GridWorldModel {

    public static final int   COW    = 16;
    public static final int   CORRAL = 32;
    public static final int   ENEMY  = 64;
    public static final int   TARGET = 128; // one agent target location
    public static final int   FORPLACE = 256; // a place in a formation
    public static final int   ENEMYCORRAL = 512; // a place in a formation

    public static final int   nbActions = 8;

    public static final int   agsByTeam = 6;
    
    public static final int   agPerceptionRatio  = 8;
    public static final int   cowPerceptionRatio = 4;    

    
    double                    PSim = 0.1; // probability of action/information failure
    double                    PMax = 0.5; // maximal value for action/information failure
    
    Location                  corralUL, corralDR;

    int                       cowsBlue = 0; // #cows the blue team puts in the corral
    int                       cowsRed  = 0; // #cows the red team puts in the corral
    int                       initialNbCows = 0;
    
    int                       maxSteps = 0; // number of steps of the simulation

    private Logger            logger   = Logger.getLogger("jasonTeamSimLocal.mas2j." + WorldModel.class.getName());

    public enum Move {
        north, south, east, west, northeast, southeast, northwest, southwest, skip 
    };


    public static WorldModel create(int w, int h, int nbAg) {
        return new WorldModel(w,h,nbAg);
    }
    
    public WorldModel(int w, int h, int nbAg) {
        super(w, h, nbAg);
    }

    public int getAgsByTeam() {
        return agsByTeam;
    }
    
    @Override 
    public boolean isFree(int x, int y) {
        return super.isFree(x,y) && !hasObject(ENEMY, x, y) && !hasObject(AGENT, x, y) && !hasObject(COW, x, y) && !hasObject(CORRAL, x, y);
    }

    public WorldView getView() {
        return (WorldView)view;
    }
    
    // upper 
    public void setCorral(Location upperLeft, Location downRight) {
        for (int l=upperLeft.y; l<=downRight.y; l++)
            for (int c=upperLeft.x; c<=downRight.x; c++)
                data[c][l] = CORRAL;
        corralUL = upperLeft;
        corralDR = downRight;
    }
    
    public boolean inCorral(Location l) {
        return l.x >= corralUL.x && l.x <= corralDR.x &&
               l.y >= corralUL.y && l.y <= corralDR.y;
    }
    
    public Location getCorralCenter() {
        return new Location( (corralUL.x + corralDR.x)/2, (corralUL.y + corralDR.y)/2);
    }

    public int getCowsBlue() {
        return cowsBlue;
    }

    public int getCowsRed() {
        return cowsRed;
    }
    
    public void setCowsBlue(int c) {
        cowsBlue = c;
    }
    public void setCowsRed(int c) {
        cowsRed = c;
    }
    
    public void setPSim(double psim) {
        PSim = psim;
    }
    public void setPMax(double pmax) {
        PMax = pmax;
    }
    
    public void setMaxSteps(int s) {
        maxSteps = s;
    }
    public int getMaxSteps() {
        return maxSteps;
    }
        
    public void removeAll(int obj) {
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                if (hasObject(obj, i, j))
                    remove(obj, i, j);
            }
        }
    }
    
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
        case north:    n =  new Location(l.x, l.y - 1); break;
        case south:  n =  new Location(l.x, l.y + 1); break;
        case east: n =  new Location(l.x + 1, l.y); break;
        case west:  n =  new Location(l.x - 1, l.y); break;
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
        return isFreeOfObstacle(l);
    }
    
    public void wall(int x1, int y1, int x2, int y2) {
        for (int i=x1; i<=x2; i++) {
            for (int j=y1; j<=y2; j++) {
                add(OBSTACLE, i, j);;
            }
        }
    }
    
    public String toString() {
        StringBuilder s = new StringBuilder("|");

        for (int i = 0; i < getWidth(); i++) {
            s.append('-');
        }
        s.append("|\n");
        String bar = s.toString();
        for (int j = 0; j < getHeight(); j++) {
            s.append('|');
            for (int i = 0; i < getWidth(); i++) {
                if (hasObject(OBSTACLE, i, j)) {
                    s.append('X');
                } else if (hasObject(AGENT, i, j)) {
                    s.append((getAgAtPos(i, j)+1)+"");
                } else if (hasObject(COW, i, j)) {
                    s.append('c');
                } else if (hasObject(ENEMY, i, j)) {
                    s.append('E');
                } else if (hasObject(CORRAL, i, j)) {
                    s.append('-');
                } else {
                    s.append(' ');
                }
            }
            s.append("|\n");
        }
        s.append(bar);
        
        return s.toString();
    }

    public static Location getNewLocationForAction(Location pos, WorldModel.Move action) {
        switch (action) {
        case west     : return new Location(pos.x-1,pos.y);
        case east     : return new Location(pos.x+1,pos.y);
        case north    : return new Location(pos.x,pos.y-1);
        case northeast: return new Location(pos.x+1,pos.y-1);
        case northwest: return new Location(pos.x-1,pos.y-1);
        case south    : return new Location(pos.x,pos.y+1);
        case southeast: return new Location(pos.x+1,pos.y+1);
        case southwest: return new Location(pos.x-1,pos.y+1);
        }
        return null;
    }

}
