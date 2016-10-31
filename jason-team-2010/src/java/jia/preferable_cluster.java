package jia;



import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.logging.Logger;

import busca.Nodo;

import arch.CowboyArch;
import arch.LocalWorldModel;
import env.ClusterModelFactory;
import env.IClusterModel;
import jason.environment.grid.Location;
import jason.asSemantics.*;
import jason.asSyntax.*;

/**
 * Gives the best cluster for the position of the group. Alternative to WofCl.
 * Use: jia.preferable_cluster(+Xg,+Yg,+XCl,+YCl,-L,-S, -N);
 * or   jia.preferable_cluster(+Xg,+Yg,-L,-S,-N);
 * Where: XCl and YCl are the positions of the cluster and Xg, Yg are the positions of the herding 
 *        group. L and S are the N locations and Sizes already sorted by preferable_cluster. L[0] is the best cluster.
 * @author gustavo
 *
 */

public class preferable_cluster extends DefaultInternalAction {	
	private static final long serialVersionUID = -1652602575376052947L;
	LocalWorldModel model;
	static Logger logger;
	Search s;
	CowboyArch arch;
	int size;
	IClusterModel ClModel;
	int n = 20;
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	arch = (CowboyArch)ts.getUserAgArch();
    	model = arch.getModel();
    	if(ClModel == null)
    		 ClModel = ClusterModelFactory.getModel(ts.getUserAgArch().getAgName());
    	Location Gr = new Location((int)((NumberTerm)args[0]).solve(),(int)((NumberTerm)args[1]).solve());
		ListTerm pos = new ListTermImpl();
		ListTerm sizs = new ListTermImpl();
    	
    	
    	
    	if(args.length == 5){
    		contCluster[] ClChosed = getClusterWith(null,Gr);
			for(int i = 0;i<ClChosed.length;i++){
				//logger.info("vvvv java 5 posicao "+i+": ("+positions[i].x+","+positions[i].y+")");
    			Location loc = ClChosed[i].v.getLocation(model);
				pos.add(ASSyntax.createStructure("pos", ASSyntax.createNumber(loc.x),ASSyntax.createNumber(loc.y)));
				sizs.add(ASSyntax.createNumber(ClChosed[i].d));
			}
    		return un.unifies(args[2], pos) &
    				un.unifies(args[3], sizs) &
    				un.unifies(args[4], new NumberTermImpl(ClChosed.length));
    	}else if(args.length == 7){
    		if(args[2].isGround() && args[3].isGround()){
    			Location Cl = new Location((int)((NumberTerm)args[2]).solve(),(int)((NumberTerm)args[3]).solve());
    			contCluster[] ClChosed = getClusterWith(Cl,Gr);
    			
    			for(int i = 0;i<ClChosed.length;i++){
    				//logger.info("vvvv java 5 posicao "+i+": ("+positions[i].x+","+positions[i].y+")");
        			Location loc = ClChosed[i].v.getLocation(model);
    				pos.add(ASSyntax.createStructure("pos", ASSyntax.createNumber(loc.x),ASSyntax.createNumber(loc.y)));
    				sizs.add(ASSyntax.createNumber(ClChosed[i].d));
    			}
        		return un.unifies(args[4], pos) &
        				un.unifies(args[5], sizs) &
        				un.unifies(args[6], new NumberTermImpl(ClChosed.length));
    			
    		}
    		contCluster[] ClChosed = getClusterWith(null,Gr);
    		for(int i = 0;i<ClChosed.length;i++){
				//logger.info("vvvv java 5 posicao "+i+": ("+positions[i].x+","+positions[i].y+")");
    			Location loc = ClChosed[i].v.getLocation(model);
				pos.add(ASSyntax.createStructure("pos", ASSyntax.createNumber(loc.x),ASSyntax.createNumber(loc.y)));
				sizs.add(ASSyntax.createNumber(ClChosed[i].d));
			}
    		return un.unifies(args[4], pos) &
    				un.unifies(args[5], sizs) &
    				un.unifies(args[6], new NumberTermImpl(ClChosed.length));
    	}
    	logger.warning("preferable_cluster not Called properly: number of Terms is wrong");
    	return null;
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
   
    private contCluster[] getClusterWith(Location befCl,Location Gr)throws Exception{
    	Vec[] Centers = ClModel.getCenters();
    	int[] NumberOfCows = ClModel.getNumCows();
    	int[] Radius = ClModel.getMaxDist();
    	int clo = -1;
    	
    	
    	if(befCl != null){
    		int d = 9;
    		for(int i =0;i<Centers.length;i++){
    			if(befCl.distanceChebyshev(Centers[i].getLocation(model))<d){
    				d = befCl.distanceChebyshev(Centers[i].getLocation(model));
    				clo = i; 
    			}
    			
    		}
    	}
    	contCluster[]   cC = new contCluster[Centers.length];
    	
    	for(int i = 0;i<Centers.length;i++){
    		boolean clotemp;
    		if(i == clo){
    			clotemp = true;
    		}else{
    			clotemp = false;
    		}
    		Location Cl = Centers[i].getLocation(model);
			int actdist = getDistances(Cl,Gr);
    		cC[i] = new contCluster(Centers[i],actdist,NumberOfCows[i],Radius[i],clotemp);
    	}
    	
    	Arrays.sort(cC);
    	return cC;
    }

    private class contCluster implements Comparable<contCluster>{
    	Vec v;
    	int n;
    	int r;
    	int d;
    	boolean clo;
    	public contCluster(Vec v, int n, int r,int d, boolean clo){
    		this.v= v;
    		this.n = n;
    		this.r = r;
    		this.d = d;
    		this.clo = clo;
    	}
		public int compareTo(contCluster arg0) {
			contCluster c = (contCluster)arg0;
			
			if(this.clo) return -1;
			if(c.clo) return  1;
			if(this.n>n && c.n<n) return -1;
			if(c.n>n && this.n<n) return  1;
			if(this.d<c.d)return -1;
			if(this.d>c.d)return  1;
			if(this.r<c.r)return -1;
			if(c.r<this.r)return  1; 
			return 0;
		}
    }
}
