package env;

import java.util.logging.Logger;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.Collections;

import jason.environment.grid.Location;

import alice.cartago.*;

/**
 * The artifact description for cartago
 *
 * @author Ricardo
 */

public class CowModelArtifact extends Artifact{
	
	CowModel cModel = new CowModel();
	

	/*
	 * Methods used in Cartago
	 */

	@OPERATION void init()
	{
		cModel.reset();
		defineObsProperty("cowprop",cModel.getCows());
		defineObsProperty("H",cModel.getSizeh());
		defineObsProperty("W",cModel.getSizew());
		/*
		   Do jeito como esta, gera uma ObsProperty que todos podem perceber
		   Para retornar apenas a um agente, a solução seria emitir um Signal
		 */
	}

	@OPERATION void cInsertCow(int id, int x, int y, int step)
	{
		cModel.insertCow(id,x,y,step);
	}

	@OPERATION void cFreePos(int x, int y) {
	
		cModel.freePos(x,y);
	}

	@OPERATION void cSetSize(int w, int h)
	{
		cModel.setSize(w,h);
	}

	/*
	 * This is used to update the property, so the agents get the cows
	 */
	@OPERATION void updateProperty()
	{
		updateObsProperty("cowprop",cModel.getCows());
		updateObsProperty("H",cModel.getSizeh());
		updateObsProperty("W",cModel.getSizew());
	}		
}
