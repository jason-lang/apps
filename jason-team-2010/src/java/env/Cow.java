package env;

import java.util.logging.Logger;
import java.io.Serializable;


/**
 * Class used to define a cow
 *
 * @author Ricardo
 */

public class Cow implements Serializable{
	/**
	 * 
	 */
	private static final long serialVersionUID = 3979318534857199194L;
	public int id; // Cow ID
	public int x,y; // Cow position
	public int step; // step in which cow was last seen
	public int clId; // the ID of the cluster containing cow

	public Cow (int id, int x, int y,int step)
	{
		this.id=id;
		this.x = x;
		this.y = y;
		this.step=step;
		this.clId=-1;
	}

	public Cow (int id, int x, int y)
	{
		this(id,x,y,0);
	}
	
}

