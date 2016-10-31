// Internal action code for project jason-team-2010

package jia;

import java.util.List;
import java.util.logging.Logger;

import busca.Nodo;

import arch.CowboyArch;
import arch.LocalWorldModel;

import env.ClusterModel;
import env.ClusterModelFactory;
import env.IClusterModel;
import env.WorldModel;
import jason.*;
import jason.environment.grid.Location;
import jason.asSemantics.*;
import jason.asSyntax.*;

/**
 * Gives the best cluster for the position of the group 
 * Use: jia.weight_of_clusters(+XCl,+YCl,+Xg,+Yg,-W, -Size);
 * or   jia.weight_of_clusters(+XCl,+YCl,+Xg,+Yg,+Xact,+Yact,-W,-Size);
 * Where: XCl and YCl are the positions of the cluster and Xg, Yg are the positions of the herding 
 *        group. W is the weight.
 * @author gustavo
 *
 */

public class weight_of_clusters extends DefaultInternalAction {
	/**
	 * 
	 */
	private static final long serialVersionUID = 7875071367882251756L;
	LocalWorldModel model;
	static Logger logger;
	Search s;
	CowboyArch arch;
	int size;
	IClusterModel ClModel;
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
	if(ClModel == null)
    		 ClModel = ClusterModelFactory.getModel(ts.getUserAgArch().getAgName());
    	arch = (CowboyArch)ts.getUserAgArch();
    	model = arch.getModel();
    	Location Cl = new Location((int)((NumberTerm)args[0]).solve(),(int)((NumberTerm)args[1]).solve());
    	Location Gr = new Location((int)((NumberTerm)args[2]).solve(),(int)((NumberTerm)args[3]).solve());
    	
    	
    	int S = getSParameter(Cl,ts);
    	int L = getDistances(Cl,Gr);
    	if(args.length == 8 && args[4].isGround() && args[5].isGround()){
    		Location actCl = new Location((int)((NumberTerm)args[4]).solve(),(int)((NumberTerm)args[5]).solve());
    		double resp = Math.abs((double)S*L/100)+1.0/(1.0+(double)actCl.distanceChebyshev(Cl));
        	return un.unifies(args[6], new NumberTermImpl(resp)) &
			un.unifies(args[7], new NumberTermImpl(size));
    	   
    	}else if(args.length == 8){
    		double resp = Math.abs((double)S*L/100);
        	return un.unifies(args[6], new NumberTermImpl(resp)) &
			un.unifies(args[7], new NumberTermImpl(size));
    	}
    	return un.unifies(args[4], new NumberTermImpl(Math.abs((double)S*L/100))) &
    			un.unifies(args[5], new NumberTermImpl(size));
    }
    private int getDistances(Location Cl, Location Gr) throws Exception{
    	s = new Search(model,Cl, model.getCorral().center(),null, false, false, false, false, false, false,null);
    	s.setMaxDistFromCluster(size);
		List<Nodo> path = Search.normalPath(s.search());
    	int ClToCo = path.size();
    	s = new Search(model,Gr, model.getCorral().center(),null, false, false, false, false, false, false, null);
    	s.setMaxDistFromCluster(size);
    	path = Search.normalPath(s.search());
    	
    	int GrToCl = path.size();
    	return ClToCo + GrToCl;
    }
    private int getSParameter(Location Cl,TransitionSystem ts){
    	Vec[] Centers = ClModel.getCenters();
    	int[] Radius = ClModel.getMaxDist();
    	int[] NumberOfCows = ClModel.getNumCows();
    	int dist = Centers[0].getLocation(model).distanceChebyshev(Cl);
    	int k = 0;
    	for(int i = 1;i<Centers.length;i++){
    		if(dist>Centers[i].getLocation(model).distanceChebyshev(Cl)){
    			dist=Centers[i].getLocation(model).distanceChebyshev(Cl);
    			k = i;
    		}		
    	}
    	size = Radius[k];
    	return (Radius[k]-ClModel.getPrefRadius())*(NumberOfCows[k]-ClModel.getPrefNCows());
    
    }
}
