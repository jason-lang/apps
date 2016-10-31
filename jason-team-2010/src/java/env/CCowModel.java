package env;

import java.util.logging.Logger;

import alice.cartago.security.*;
import alice.cartago.*;
import java.lang.String;

/**
 * Class used to centralize cows, using cartago
 *
 * @author Ricardo
 */

public class CCowModel implements ICowModel{
	private Logger logger = Logger.getLogger(CowModel.class.getName());
	
	private UserCredential cred;
	private ICartagoContext cWps;
	private ArtifactId cArt;
	private String end;
	private String wpsName;
	private String cartagoRole;
	private String artName;
	
	private int gW,gH;
	private Cow[] cows;
	
	public CCowModel(String end, String wpsName, String cartagoRole, String artName, String agName)
	{
		this.end = end;
		this.wpsName = wpsName;
		this.cartagoRole = cartagoRole;
		this.artName = artName;
		cred = new UserIdCredential(agName);
		try {
			cWps = CartagoService.joinWorkspace(this.wpsName,this.end,this.cartagoRole,cred);
			cArt = cWps.lookupArtifact(this.artName,-1);
		} catch (Exception e) {
			logger.severe("Unable to get artifact\n" + e);
			e.printStackTrace();
		}
	}

	/**
	 * Clears the model (should be called when ending an instance of the simulation).
	 */
	public synchronized void reset()
	{
			try{
				cWps.use(null,cArt,new Op("init"),null,null,-1);
			} catch (Exception e) {
				logger.severe("Unable to use artifact\n"+e);
			}
			logger.info("model has been reset");
	}

	/**
	 * Sets the grid size. when more its called more than once for the same parameters, nothing happens
	 * for the subsequent calls with the same parameteres.
	 */
	public synchronized void setSize(int w, int h) // tera que ter cuidado para apenas um agente arrumar o tamanho quando comecar: DONE
	{
		
		try{
			cWps.use(null,cArt,new Op("cSetSize",w,h),null,null,-1);
		} catch (Exception e) {
			logger.severe("Unable to use artifact\n"+e);
		}
		logger.info("Got size: " + w +", " + h);

	}

	/**
	 * removes any cow from formation
	 */
	public void freePos(int x, int y)
	{
		try{
			cWps.use(null,cArt,new Op("cFreePos",x,y),null,null,-1);
		} catch (Exception e) {
			logger.severe("Unable to use artifact\n"+e);
		}
	}

	/**
	 * Inserts a cow in.tion, removing any cow that was in.tion
	 */
	public void insertCow(int id, int x, int y, int step)
	{
		try{
			cWps.use(null,cArt,new Op("cInsertCow",id,x,y,step),null,null,-1);
		} catch (Exception e) {
			logger.severe("Unable to use artifact\n"+e);
		}
	}
	
	public void updateCows() {
		try {
			cWps.use(null,cArt,new Op("updateProperty"),null,null,-1);
		} catch (Exception e) {
			logger.severe("Unable to use artifact\n"+e);
		}
		try {
			gH = cWps.observeProperty(cArt,"H").intValue();
			gW = cWps.observeProperty(cArt,"W").intValue();
			cows = (Cow[])(cWps.observeProperty(cArt,"cowprop").getValue());
		} catch (Exception e) {
			logger.severe("Unable to observe artifact\n"+e);
		}
	}
	
	public Cow[] getCows()
	{
		return cows;
		//return  cows.clone();
	}

	public int getSizeh(){
		return gH;
	}
	public int getSizew(){
		return gW;
	}
	
}
