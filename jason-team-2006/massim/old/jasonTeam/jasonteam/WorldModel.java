package jasonteam;

public class WorldModel {
	
	public static final byte UNKNOWN  = 0;
	public static final byte ALLY     = 2;
	public static final byte ENEMY    = 4;
	public static final byte OBSTACLE = 8;
	public static final byte GOLD     = 16;
	public static final byte DEPOT    = 32;
	public static final byte EMPTY    = 64;
	
	int width, height;
	byte[][] data = null;
	
	int depotx, depoty;	
	
	// singleton pattern
	private static WorldModel model = null;
	public static WorldModel create(int w, int h) {
		if (model == null) {
			model = new WorldModel(w,h);
		}
		return model;
	}
    
    public static void destroy() {
    	model = null;
    }
	
	private WorldModel(int w, int h) {
		width = w;
		height = h;
		
		// int data
		data = new byte[width][height];
		for (int i=0; i<width; i++) {
			for (int j=0; j<height; j++) {
				data[i][j] = UNKNOWN;
			}
		}
	}

	public void setDepot(int x, int y) {
		depotx = x;
		depoty = y;
		data[depotx][depoty] = DEPOT;
	}

	public void add(byte value, int x, int y) {
		data[x][y] |= value;
	}
	
	public void clearAgView(int x, int y) {
		byte e1 = ~(ENEMY+ALLY+GOLD);
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
	
	public boolean isFree(int x, int y) {
		return y >= 0 && y < height && x >= 0 && x < width 
				&& (data[x][y] & OBSTACLE) == 0
				&& (data[x][y] & ALLY) == 0
				&& (data[x][y] & ENEMY) == 0;
	}
	
	public boolean isUnknown(int x, int y) {
		return y >= 0 && y < height && x >= 0 && x < width && (data[x][y] == UNKNOWN);
	}
}
