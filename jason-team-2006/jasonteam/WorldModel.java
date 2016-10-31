package jasonteam;

import java.util.HashSet;
import java.util.Set;

public class WorldModel {
	
	public static final int UNKNOWN  = 0;
	public static final int ALLY     = 2;
	public static final int ENEMY    = 4;
	public static final int OBSTACLE = 8;
	public static final int GOLD     = 16;
	public static final int DEPOT    = 32;
	public static final int EMPTY    = 64;
	
	int width, height;
	int[][] data = null;
	
	Location depot;	

	Location[] agPos;

    Set<Integer> agWithGold; // which agent is carrying gold
    
	// singleton pattern
	private static WorldModel model = null;
	synchronized public static WorldModel create(int w, int h, int nbAgs) {
		if (model == null) {
			model = new WorldModel(w,h,nbAgs);
		}
		return model;
	}
    
    public static WorldModel get() {
        return model;
    }
    
    public static void destroy() {
    	model = null;
    }
	
	private WorldModel(int w, int h, int nbAgs) {
		width = w;
		height = h;
		
		// int data
		data = new int[width][height];
		for (int i=0; i<width; i++) {
			for (int j=0; j<height; j++) {
				data[i][j] = UNKNOWN;
			}
		}
		
        agPos = new Location[nbAgs];
		for (int i=0; i<agPos.length; i++) {
			agPos[i] = new Location(-1,-1);
		}
        
        agWithGold = new HashSet<Integer>();
	}

    public int getWidth() { return width; }
    public int getHeight() { return height; }
    public Location getDepot() { return depot; }
    public int getNbOfAgs() { return agPos.length; }

    public boolean hasObject(int obj, int x, int y) {
        return  y >= 0 && y < height && x >= 0 && x < width && (model.data[x][y] & obj) != 0;
    }
    
    public boolean isCarryingGold(int ag) {
        return agWithGold.contains(ag);
    }

    public void setDepot(int x, int y) {
        depot = new Location(x,y);
		data[x][y] = DEPOT;
	}

	public void add(int value, int x, int y) {
		data[x][y] |= value;
	}
	
    public void remove(int value, int x, int y) {
        data[x][y] &= ~value;
    }
    
    
	public void setAgPos(int ag, int x, int y) {
		agPos[ag] = new Location(x,y);
	}
	
	public Location getAgPos(int ag) {
		try {
			if (agPos[ag].x == -1) 
				return null;
			else
				return agPos[ag];
		} catch (Exception e) {
			return null;
		}
	}
    
    public void setAgCarryingGold(int ag) {
        agWithGold.add(ag);
    }
    public void setAgNotCarryingGold(int ag) {
        agWithGold.remove(ag);
    }
	
    public void clearAgView(int agId) {
        clearAgView(getAgPos(agId).x, getAgPos(agId).y);
    }
    
	public void clearAgView(int x, int y) {
		int e1 = ~(ENEMY+ALLY+GOLD);
		if (x > 0 && y > 0)         { data[x-1][y-1] &= e1; } // nw
		if (y > 0         )         { data[x][y-1]   &= e1; } // n
		if (x < (width-1) && y > 0) { data[x+1][y-1] &= e1; } // ne
		
		if (x > 0         )         { data[x-1][y]   &= e1; } // w
		                              data[x][y]     &= e1;   // cur
		if (x < (width-1))          { data[x+1][y]   &= e1; } // e

		if (x > 0 && y < (height-1))          { data[x-1][y+1] &= e1; } // sw
		if (y < (height-1))                   { data[x][y+1]   &= e1; }  // s
		if (x < (width-1) && y < (height-1))  { data[x+1][y+1] &= e1; }  // se
	}
	
	public boolean isFree(Location l) {
		return isFree(l.x, l.y);
	}
	public boolean isFree(int x, int y) {
		return y >= 0 && y < height && x >= 0 && x < width 
				&& (data[x][y] & OBSTACLE) == 0
				&& (data[x][y] & ALLY) == 0
				&& (data[x][y] & ENEMY) == 0;
	}

    public boolean isFreeOfObstacle(Location l) {
    	return isFreeOfObstacle(l.x, l.y);
    }
    public boolean isFreeOfObstacle(int x, int y) {
        return y >= 0 && y < height && x >= 0 && x < width 
                && (data[x][y] & OBSTACLE) == 0;
    }
	
	public boolean isUnknown(Location l) {
		return l.y >= 0 && l.y < height && l.x >= 0 && l.x < width && (data[l.x][l.y] == UNKNOWN);
	}
}
