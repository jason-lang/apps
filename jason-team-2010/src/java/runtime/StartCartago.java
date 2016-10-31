package runtime;

import java.util.logging.Logger;

import env.ClusterModelFactory;
import env.CowModel;
import env.CowModelFactory;
import alice.cartago.*;
import alice.cartago.tools.*;
import alice.cartago.security.*;

public class StartCartago {
	private static int port=22345;
	private static String end = "localhost:22345";
	private static String wpsName1 = "cowmodel";
	private static String wpsName2 = "clustermodel";
	private static String cartagoRole = "creator";
	private static String artName1 = "cModel";
	private static String artName2 = "clModel";
	private static String artClass1 = "env.CowModelArtifact";
	private static String artClass2 = "env.ClusterModelArtifact";
	private static Logger logger = Logger.getLogger(CowModel.class.getName());
	public static void main(String[] args) throws Exception
	{
		UserCredential crcred = new UserIdCredential(cartagoRole);

		CartagoService.installNode(port);

		ICartagoContext ctx = CartagoService.joinWorkspace("default",end,cartagoRole,crcred);

		ctx.createWorkspace(wpsName1);
		ctx.createWorkspace(wpsName2);

		//CartagoService.registerLogger(wpsName1,new BasicLogger());
		//CartagoService.registerLogger(wpsName1,new BasicLoggerOnFile("cartago.log"));

		ICartagoContext cModel = ctx.joinWorkspace(wpsName1,end,cartagoRole,crcred);
		ICartagoContext clModel = ctx.joinWorkspace(wpsName2,end,cartagoRole,crcred);
		
		
		
		
		
		if(!CowModelFactory.centralized)
			cModel.makeArtifact(artName1,artClass1,ArtifactConfig.DEFAULT_CONFIG, -1);
		
		
		if(!ClusterModelFactory.centralized)
			clModel.makeArtifact(artName2,artClass2,ArtifactConfig.DEFAULT_CONFIG, -1);
		
	}
}

