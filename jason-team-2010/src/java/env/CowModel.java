package env;

import java.util.logging.Logger;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Collections;


/**
 * Class used to centralize cows
 *
 * @author Ricardo Hahn 
 */

public class CowModel implements ICowModel{

	private Map <Integer,Cow> cows = Collections.synchronizedMap(new HashMap<Integer,Cow>()); 

	private int[][] grid; // contains the cows in their position 
	
	private int gH = -1, gW = -1; // the grid size 
	
	private Logger logger = Logger.getLogger(CowModel.class.getName());
	
	private int nop=0; // number of operations since last check
	
	public CowModel()
	{
	}

	/**
	 * Clears the model (should be called when ending an instance of the simulation).
	 */
	public synchronized void reset()
	{
		cows.clear();
		gH=gW=-1;
		logger.info("model has been reset");
	}

	/**
	 * Sets the grid size. when more its called more than once for the same parameters, nothing happens
	 * for the subsequent calls with the same parameters.
	 */
	public synchronized void setSize(int w, int h) // tera que ter cuidado para apenas um agente arrumar o tamanho quando comecar: DONE
	{
		if(w==gW && h==gH) // the grid already has the right size (or its already been updated) 
			return;
		reset();
		gW=w; gH=h;
		grid = new int[w+1][h+1];
		for(int i=0; i<=w; i++)
			for(int j=0; j<=h; j++)
				grid[i][j]=-1;
		logger.info("Got size: " + gW +", " + gH);

	}

	/**
	 * removes any cow from position
	 */
	public void freePos(int x, int y)
	{
		synchronized(cows) {
			if(grid[x][y]<0) // already free
				return;
			//logger.info("- removing "+grid[x][y]+" from map ("+x+","+y+")");
			cows.remove(grid[x][y]);
			//logger.info("- removing "+grid[x][y]+" from map ("+x+","+y+")");
			grid[x][y]=-1;
		}
	}

	/**
	 * Inserts a cow in position, removing any cow that was in position
	 */
	public void insertCow(int id, int x, int y, int step)
	{
		
		synchronized(cows) {
			freePos(x,y);
			Cow toRem = cows.get(id);
			if(toRem != null) {
				freePos(toRem.x,toRem.y);
			}
			cows.put(id, new Cow(id,x,y,step));
			grid[x][y]=id;
		}

		/*//debugging purposes
		if(++nop > 1000) {
			if(checkState())
				logger.info("CowModel is OK");
			else
				logger.info("CowModel is NOT OK");
		}
		*/
	}
	
	/**
	 * Used for debugging
	 * Returns true if cows and grid are consistent, false otherwise.
	 */
	public boolean checkState() // debugging purposes
	{
		String str = new String();
		int[][] mapa = new int[gW+1][gH+1];
		
		nop=0;
		
		for(int x=0;x<=gW;++x)
			for(int y=0;y<=gH;++y)
				mapa[x][y]=-1;
		synchronized(cows) {
			Iterator it = cows.keySet().iterator();
			while( it.hasNext() ) {
				Cow cw = cows.get(it.next());
				if(mapa[cw.x][cw.y]>=0)
					return false;
				mapa[cw.x][cw.y]=cw.id;
			}
			for(int x=0;x<=gW;x++)
				for(int y=0;y<=gH;y++)
					if(mapa[x][y]!=grid[x][y])
					{
						logger.info("position ("+x+","+y+") "+mapa[x][y]+" "+grid[x][y]+" NOT OK");
						return false;
					}
		}
		return true;
	}
	
	public Cow[] getCows()
	{
		Cow[] a = new Cow[cows.size()];
		return (Cow[]) (cows.values()).toArray(a).clone();
	}
	
	public void updateCows() // it's not needed, once cows are already local
	{
	}
	
	public int getSizeh(){ 
		return gH;
	}
	public int getSizew(){
		return gW;
	}
		
}
