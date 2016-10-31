package env;

import java.util.Map;
import java.util.Vector;
import java.util.List;
import java.util.logging.Logger;

import alice.cartago.ArtifactId;
import alice.cartago.CartagoException;
import alice.cartago.CartagoService;
import alice.cartago.ICartagoContext;
import alice.cartago.Op;
import alice.cartago.security.UserCredential;
import alice.cartago.security.UserIdCredential;

import jia.Vec;

public class CClusterModel implements IClusterModel,Runnable {
	private Logger logger = Logger.getLogger(ClusterModel.class.getName());
	
	private UserCredential cred;
	private ICartagoContext cWps;
	private ArtifactId cArt;
	private String end;
	private String wpsName;
	private String cartagoRole;
	private String artName;
	
	

	private static class buffer{
		public int actStep = -1;
		public int clStep;
		public int[] alloc;
		public Vec[] Centers;
		public int[][] data;
		public int[] map= new int[1000];
		public int[] maxDist;
		public int[] numCows;
		public int numberOfCows;
		public int prefNCows;
		public int prefRadius;
		public double prefkPTC;
		public ICowModel cowModel = CowModelFactory.getModel("bufferFromClusterModel");
	}
	public static buffer bf = new buffer();
	

	
	public void update(){
		this.run();
		try {
			int i = 0;
			cWps.use(null,cArt, new Op("update"),null, null, -1);
			logger.info("HHHJ"+(i++));
			bf.alloc = (int[])cWps.observeProperty(cArt, "clusterAlloc").getValue();
			logger.info("HHHJ"+(i++));
			bf.Centers = (Vec[]) cWps.observeProperty(cArt, "clusterCenters").getValue();
			logger.info("HHHJ"+(i++));
			bf.data = (int[][]) cWps.observeProperty(cArt, "clusterData").getValue();
			logger.info("HHHJ"+(i++));
			bf.map = (int[]) cWps.observeProperty(cArt, "clusterMap").getValue();
			logger.info("HHHJ"+(i++));
			bf.maxDist = (int[])cWps.observeProperty(cArt, "clusterRadius").getValue();
			logger.info("HHHJ"+(i++));
//			int[] MaxDist= bf.map.clone();
			
//			String str =  new String();
//			for(int j = 0;j<MaxDist.length;j++){
//				str+=","+MaxDist[j];
//			}
//			logger.info("HHHJ"+str);
			
			bf.numCows = (int[])cWps.observeProperty(cArt, "clusterNumCows").getValue();
			logger.info("HHHJ"+(i++));
			bf.numberOfCows = (Integer)cWps.observeProperty(cArt, "clusterNumber").getValue();
			logger.info("HHHJ"+(i++));
			bf.prefNCows = (Integer)cWps.observeProperty(cArt, "clusterPrefNCows").getValue();
			logger.info("HHHJ"+(i++));
			bf.prefRadius = (Integer)cWps.observeProperty(cArt, "clusterPrefRadius").getValue();
			logger.info("HHHJ"+(i++));
			bf.prefkPTC =  (Double)cWps.observeProperty(cArt, "clusterPrefKPTC").getValue();
			logger.info("HHHJ"+(i++));
			logger.info("HHHJ "+bf.prefkPTC);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
 	public CClusterModel(String end, String wpsName, String cartagoRole, String artName, String agName)

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
		}
	
		try {
			cWps.use(null, cArt, new Op("init"), null, null, -1);
		} catch (CartagoException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
					
		
	}
	

	public int[] getAlloc() {
		return bf.alloc;
	}

	public Vec[] getCenters() {
		return bf.Centers;
	}

	public int[][] getData() {
		return bf.data;
	}
	public int[] getMap(){
	/*	
		try{
		 return bf.map = (int[]) cWps.observeProperty(cArt, "clusterMap").getValue();
		}catch (Exception e){
			e.printStackTrace();
		}
	*/	
		return bf.map.clone();
	}

	public int[] getMaxDist() {
		return bf.maxDist;
	}

	public int[] getNumCows() {
		return bf.numCows;
	}

	public int getNumberOfCluster() {
		return bf.numberOfCows;
	}

	public synchronized void insertTree(int x, int y) {
		try {
			cWps.use(null, cArt, new Op("clusterInsertTree",x,y), null, null, -1);
		} catch (CartagoException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
	}

	public void setStepcl(int step) {
		if(step>bf.clStep)	bf.clStep = step;
		try {
			cWps.use(null, cArt, new Op("clusterSetStep",step), null, null, -1);
		} catch (CartagoException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

	}
	public void run() {
		try {
			cWps.use(null, cArt, new Op("clusterSetCows",bf.cowModel.getCows(),bf.cowModel.getSizeh(),bf.cowModel.getSizew()), null, null, -1);
		} catch (CartagoException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		if(bf.actStep<bf.clStep){
			bf.actStep = bf.clStep;
			try {
				cWps.use(null, cArt, new Op("clusterRun"), null, null, -1);
			} catch (CartagoException e) {
				e.printStackTrace();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			update();
		}
		
	}
	public void changeClusterer(int a){
		try {
			cWps.use(null, cArt, new Op("clusterCClusterer",a), null, null, -1);
		} catch (CartagoException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

	}

	public void changeMaxDist(int a) {
		try {
			cWps.use(null, cArt, new Op("clustercMaxDist",a),null, null, -1);
		} catch (CartagoException e){
			e.printStackTrace();
		} catch (InterruptedException e){
			e.printStackTrace();
		}
		
	}

	public void changePTCprop(int k) {
		try {
			cWps.use(null, cArt, new Op("clusterPTCP",k),null, null, -1);
		} catch (CartagoException e){
			e.printStackTrace();
		} catch (InterruptedException e){
			e.printStackTrace();
		}
		
	}

	public void changeWCprop(int radius, int nCows) {
		try {
			cWps.use(null, cArt, new Op("clusterWCP",radius,nCows),null, null, -1);
		} catch (CartagoException e){
			e.printStackTrace();
		} catch (InterruptedException e){
			e.printStackTrace();
		}
	}
	public int getPrefNCows() {
		return bf.prefNCows;
	}

	public int getPrefRadius() {
		return bf.prefRadius;

	}

	public double getPrefkPTC() {
		return bf.prefkPTC;
	}
	public void setCows(Cow[] c, int H, int W) {
		try {
			cWps.use(null, cArt, new Op("clusterSetCows",c,H,W),null, null, -1);
		} catch (CartagoException e){
			e.printStackTrace();
		} catch (InterruptedException e){
			e.printStackTrace();
		}
		
	}

}
