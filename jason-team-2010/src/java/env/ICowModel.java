package env;


/**
 * Interface for cows centralization
 *
 * @author Ricardo
 */

public interface ICowModel {
		
	/**
	 * Clears the model (should be called when ending an instance of the simulation).
	 */
	public void reset();
	
	/**
	 * Sets the grid size. 
	 */
	public void setSize(int w, int h);
	
	/**
	 * removes any cow from position
	 */
	public void freePos(int x, int y);
	
	/**
	 * Inserts a cow in position, removing any cow that was in position
	 */
	public void insertCow(int id, int x, int y, int step);
		
	public void updateCows();
	public Cow[] getCows();
	public int getSizeh();
	public int getSizew();
		
}
