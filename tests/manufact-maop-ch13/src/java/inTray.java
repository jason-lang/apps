import cartago.Artifact;
import cartago.OPERATION;
import cartago.INTERNAL_OPERATION;
import cartago.ObsProperty;
import java.util.Random;

/**
 *      Artifact simulating the appearance of manufacturing orders, generated at random intervals. 
 */
public class inTray extends Artifact {
    
    @OPERATION public void init()  {
        // observable properties   
        defineObsProperty("order", 1);
		execInternalOp("generateOrders");
    }

    @INTERNAL_OPERATION void generateOrders() {
		Random generator = new Random();
		ObsProperty order = getObsProperty("order");
		while (true){
			await_time((generator.nextInt(501)+500)*3);
			order.updateValue(order.intValue()+1);
		}
    }
    
}

