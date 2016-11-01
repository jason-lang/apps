// CArtAgO artifact code for project smadasMAPC2013

package artifacts;

import cartago.*;

public class Test extends Artifact {
	void init(int initialValue) {
		defineObsProperty("count2", initialValue);
		System.out.println("dasdsa dsad sadasd asds ada");
	}
	
	@OPERATION
	void inc() {
		ObsProperty prop = getObsProperty("count2");
		prop.updateValue(prop.intValue()+1);
		signal("tick");
		System.out.println("inccccccccc called");
	}
	
	
}

