package jia;





import java.util.logging.Logger;

import arch.CowboyArch;
import arch.LocalWorldModel;
import env.ClusterModel;
import env.ClusterModelFactory;
import env.IClusterModel;


import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Term;
import jason.environment.grid.Location;


/**
 * Gives the perception of clusters.
 * 
 * Use: jia.getclusters(-N,-Cl,-Size); 
 * where: N is the number of Clusters and Cl and Size are the position and Size (Radius), respectively, of the clusters;
 *
 * @author Gustavo Pacianotto Gouveia
 */

public class getclusters extends DefaultInternalAction {
	static Logger logger = null;
	IClusterModel cM;
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception{
        if (logger == null) logger = ts.getLogger();
	if(cM == null) cM = ClusterModelFactory.getModel(ts.getUserAgArch().getAgName());
		Vec[] Center = cM.getCenters();
		int n = cM.getNumberOfCluster();
		int[] maxDist = cM.getMaxDist();
		CowboyArch arch = (CowboyArch)ts.getUserAgArch();
		LocalWorldModel model = arch.getModel();
		
		ListTerm Cl = new ListTermImpl();
		for (int i = 0;i<n;i++) {
			Location l = Center[i].getLocation(model);
			logger.info("HHHasl we have "+n+" clusters, and the "+i+"th is at ("+l.x+","+l.y+")");
			Cl.add(ASSyntax.createStructure("pos", ASSyntax.createNumber(l.x),ASSyntax.createNumber(l.y)));	
		}
		ListTerm Sizes = new ListTermImpl();
		for(int i = 0;i<n;i++){
			Sizes.add(ASSyntax.createNumber(maxDist[i]));
		}

		return un.unifies(args[0], ASSyntax.createNumber(n))
			&  un.unifies(args[1], Cl)
			&  un.unifies(args[2], Sizes);			
	}
	
	
}
