package env;

import java.lang.String;

public class CowModelFactory {
	static private ICowModel cModel;
	static public boolean centralized=true;
	private static String end = "localhost:22345";//"promas2:22345";
	private static String wpsName = "cowmodel";
	private static String cartagoRole = "cowboy";
	private static String artName = "cModel";
	
	public static ICowModel getModel(String agName)
	{
		if(centralized) {
			synchronized(CowModelFactory.class) {
				if(cModel == null)
					return cModel = new CowModel();
				else
					return cModel;
			}
		}
		else{
			try{	
				Thread.sleep(3);
			}catch(Exception e){
				e.printStackTrace();
			}
			return new CCowModel(end,wpsName,cartagoRole,artName,agName+"Co"+System.currentTimeMillis());
		}
	}
}
