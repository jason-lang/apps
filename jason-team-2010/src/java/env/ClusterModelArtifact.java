package env;

import java.util.logging.Logger;
import alice.cartago.*;






public class ClusterModelArtifact extends Artifact {
	
	private Logger logger = Logger.getLogger(ClusterModelArtifact.class.getName());
	private ClusterModel model = ClusterModelFactory.getModelCent();

	@OPERATION void init(){
		
		new Thread((Runnable)model).start();
		//defineObsProperty("clusterAssign",calculate());
		defineObsProperty("clusterAlloc",model.getAlloc());
		//logger.info("HHH init passou alloc");
		defineObsProperty("clusterCenters",model.getCenters());
		//logger.info("HHH init passou centers");
		defineObsProperty("clusterData",model.getData());
		//logger.info("HHH init passou data");
		defineObsProperty("clusterMap",model.getMap());
		//logger.info("HHH init passou map");
		defineObsProperty("clusterRadius",model.getMaxDist());
		//logger.info("HHH init passou maxdist");
		defineObsProperty("clusterNumCows",model.getNumCows());
		//logger.info("HHH init passou humcows");
		defineObsProperty("clusterNumber",model.getNumberOfCluster());
		//logger.info("HHH init passou numberofcluster");
		defineObsProperty("clusterPrefNCows",model.getPrefNCows());
		//logger.info("HHH init passou prefncows");
		defineObsProperty("clusterPrefRadius",model.getPrefRadius());
		//logger.info("HHH init passou prefradius");
		defineObsProperty("clusterPrefKPTC",model.getPrefkPTC());
		//logger.info("HHH init passou prefkptc");
		logger.info("inicializou");
		
	}
	
	@OPERATION void update(){
			logger.info("HHH updating clusterM");
			updateObsProperty("clusterAlloc",model.getAlloc());
			//logger.info("HHH updated clusterL with kPTC = "+model.getPrefkPTC());
			updateObsProperty("clusterCenters",model.getCenters());
			//logger.info("HHH updated clusterL with kPTC = "+model.getPrefkPTC());
			updateObsProperty("clusterData",model.getData());
			updateObsProperty("clusterMap",model.getMap());
			//int[] MaxDist= model.getMaxDist();
			
			//String str =  new String();
		//	for(int i = 0;i<MaxDist.length;i++){
		//		str+=","+MaxDist[i];
		//	}
		//	logger.info("HHHJ"+str);
			
			updateObsProperty("clusterRadius",model.getMaxDist());
			updateObsProperty("clusterNumCows",model.getNumCows());
			updateObsProperty("clusterNumber",model.getNumberOfCluster());
			updateObsProperty("clusterPrefNCows",model.getPrefNCows());
			updateObsProperty("clusterPrefRadius",model.getPrefRadius());
			updateObsProperty("clusterPrefKPTC",model.getPrefkPTC());
			logger.info("HHH updated clusterL with kPTC = "+model.getPrefkPTC());
	}
	
	@OPERATION void updateAlloc(){
		updateObsProperty("clusterAlloc",model.getAlloc());
	}
	@OPERATION void updateCenters(){
		updateObsProperty("clusterCenters",model.getCenters());
	}
	@OPERATION void updateData(){
		updateObsProperty("clusterData",model.getData());
	}
	@OPERATION void updateMap(){
		updateObsProperty("clusterMap",model.getMap());
	}
	@OPERATION void updateRadius(){
		updateObsProperty("clusterRadius",model.getMaxDist());
	}
	@OPERATION void updateNumCows(){
		updateObsProperty("clusterNumCows",model.getNumCows());
	}
	@OPERATION void updateClusterNumber(){
		updateObsProperty("clusterNumber",model.getNumberOfCluster());
	}
	@OPERATION void updatePrefNCows(){
		updateObsProperty("clusterPrefNCows",model.getPrefNCows());
	}
	@OPERATION void updatePrefRadius(){
		updateObsProperty("clusterPrefRadius",model.getPrefRadius());
	}
	@OPERATION void updatePrefKPTC(){
		updateObsProperty("clusterPrefKPTC",model.getPrefkPTC());
	}
	/*
	@OPERATION void updateAssign(){
		updateObsProperty("clusterAssign",calculate());
	}
	*/

	/*
	@OPERATION void calculateArt(){
		calculate();
	}
	*/
	@OPERATION void clusterCClusterer(int a){
		//logger.info("HHH clCCclusterer");
		model.changeClusterer(a);
	}
	@OPERATION void clusterInsertTree(int x, int y){
		//logger.info("HHH insertTreee");
		model.insertTree(x,y);
	}
	@OPERATION void clusterSetStep(int step){
		//logger.info("HHH setting step");
		model.setStepcl(step);
	}
	@OPERATION void clusterRun(){
		//logger.info("HHH runing");
		new Thread((Runnable)model).start();
	}
	@OPERATION void clustercMaxDist(int a){
		//logger.info("HHH cCMaxDist");
		model.changeMaxDist(a);
	}
	
	@OPERATION void clusterSetCows(Cow[] c,int H, int W){
		logger.info("HHHH ->>>setting cows"+c.length);
		model.setCows(c, H, W);
	}
	
	@OPERATION void clusterPTCP(int k){
		//logger.info("HHH PTPC");
		model.changePTCprop(k);
	}
	@OPERATION void clusterWCP(int radius, int nCows){
		//logger.info("HHH WCPROP");
		model.changeWCprop(radius,nCows);
	}
}
