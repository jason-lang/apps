// CArtAgO artifact code for project testjacamo

package testjacamo;

import cartago.*;

public class Team extends Artifact {
	void init(int initialValue) {
		defineObsProperty("count", initialValue);
	}

	@OPERATION
	void inc() {
		ObsProperty prop = getObsProperty("count");
		prop.updateValue(prop.intValue()+1);
//		signal("tick");
	}
}

