package env;

public class ClusterModelFactory {
	static private IClusterModel clModel;
	static public boolean centralized=true;
	private static String end = "localhost:22345";//"promas2:22345";
	private static String wpsName = "clustermodel";
	private static String cartagoRole = "cowboy";
	private static String artName = "clModel";
	private static ClusterModel clModelC=null;
	
	public static IClusterModel getModel(String agName)
	{
		if(centralized) {
			synchronized(ClusterModelFactory.class) {
				if(clModel == null)
					return clModel = new ClusterModel();
				else
					return clModel;
			}
		}
		else{
			try {
				Thread.sleep(3);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			return new CClusterModel(end,wpsName,cartagoRole,artName,agName+"Cl"+System.currentTimeMillis());
		}
	}
	public static ClusterModel getModelCent(){
		synchronized(ClusterModelFactory.class) {
			if(clModelC == null)
				return clModelC = new ClusterModel();
			else
				return clModelC;
		}
	}
}
