package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.ListTerm;
import jason.asSyntax.ListTermImpl;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.List;
import java.util.logging.Logger;

import arch.CowboyArch;
import arch.LocalWorldModel;
import busca.Nodo;
import env.ClusterModelFactory;
import env.IClusterModel;
import env.WorldModel;
import env.ClusterModel;

/**
 * Gives the locations for herding a specific cluster of cows. 
 *   Is better use the second implementation (the one with X and Y, to avoid problems caused by the 
 * synchronization of the threads.
 * Use: jia.position_to_cluster(+X, +Y, +N, -L)
 * Where: (X,Y) is the position of the cluster, N is the number of agents, L are the locations.
 * @author Gustavo
 *
 */

/* This Internal Action isn't already tested!
 * TODO Test the formation and the locations
 * 		-Is firstFreeLocation right implemented?
 * 		-Is the Herding direction right?
 * 		-Is there any problem with the Id of the cluster?
 * TODO Think on the possibility of handling whit the center of the cluster
 *      to avoid problems with synchronization.
 */

public class position_to_cluster extends DefaultInternalAction {
	


	private static final long serialVersionUID = 1L;
	static Logger logger = null;
	
	private double angular_dis_bet_ag = 140.0*Math.PI/180.0;
	private double ct = 1;
	LocalWorldModel model;
	Search s;
	int[] radius;
	int n;
	List<Nodo> path;
	IClusterModel cModel;	
	CowboyArch arch;
	public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception{
		
		if (logger == null) logger = ts.getLogger();
		if(cModel == null) cModel = ClusterModelFactory.getModel(ts.getUserAgArch().getAgName());
		arch       = (CowboyArch)ts.getUserAgArch();		
		Vec dir = new Vec(0,0);
		model = arch.getModel();
		ListTerm pos = new ListTermImpl();
		Vec[] centers = cModel.getCenters();
		radius = cModel.getMaxDist();
		if(args[0].isNumeric() && args[1].isNumeric() && args[2].isNumeric()){
			n = 0;
			int x = (int)((NumberTerm)args[0]).solve();
			int y = (int)((NumberTerm)args[1]).solve();
			
			int dist = centers[0].getLocation(model).distanceChebyshev(new Location(x,y));
			int dist2;
			for(int i = 1;i<centers.length;i++){
				dist2 = centers[i].getLocation(model).distanceChebyshev(new Location(x,y));
				if(dist2<dist){
					dist = dist2;
					n = i;
				}
			}
			int numAg = (int)((NumberTerm)args[2]).solve(); 
			dir = getDirection(centers[n]).newMagnitude((double)radius[n]*cModel.getPrefkPTC());
			
			Location[] positions = new Location[numAg];
			if(numAg == 1) {
				positions[0] = centers[n].sub(dir).getLocation(model);
			}else{
				
				double angle = ((new Vec(0,0)).sub(dir)).t - angular_dis_bet_ag/2.0;
				double angle_step = angular_dis_bet_ag/((double)numAg-1.0);
				
				for(int i = 0;i<numAg;i++){
					Vec temp = dir;
					temp = dir.newAngle(angle_step*(double)i+angle);
					positions[i] = firstFreeLoc(temp,centers[n]);
				}
			}
			
			for(int i = 0;i<numAg;i++){
				pos.add(ASSyntax.createStructure("pos", ASSyntax.createNumber(positions[i].x),ASSyntax.createNumber(positions[i].y)));
			}

		}else{
    		ts.getAg().getLogger().info("vvvv The parameters are wrong, all three arguments should be Numerical");
		}
		
		return un.unifies(args[3], pos);
	}
	
	private Vec getDirection(Vec from) throws Exception{
	
		s = new Search(model,from.getLocation(model), model.getCorral().center(),null, false, false, false, false, false, false, arch);
	//	s.setSearchWithCluster(radius[n]);
	//	s.setMaxDistFromCluster(radius[n]);
		
		path = Search.normalPath(s.search());
		int n = path.size();
		Location temp;

		if(//n > model.getCorral().center().distanceChebyshev(from.getLocation(model)) &&
				//model.getCorral().center().distanceChebyshev(from.getLocation(model))>4){
				path.size()>4){
			temp = Search.getNodeLocation(path.get(n-4));
		}else{
			temp = model.getCorral().center();
		}
		Vec tempvec = new Vec(model,temp);
		return tempvec.sub(from);
	}
	
	private Location firstFreeLoc(Vec displacement, Vec Origin){  
		Location loc = Origin.getLocation(model);
		int maxSize = (int)displacement.r;
		
		for(int i = 0;i<=maxSize;i++){
			Location temp = (displacement.newMagnitude(i)).add(Origin).getLocation(model);
			if((!model.inGrid(temp)) ||
					model.hasObject(WorldModel.OBSTACLE, temp) || 
					model.hasObject(WorldModel.FENCE, temp) || 
					model.hasObject(WorldModel.SWITCH, temp) || 
					model.hasObject(WorldModel.CORRAL, temp)) {	
				return loc;
			}
			loc = temp;
		}
		return loc;
	}
	
	
	
}

