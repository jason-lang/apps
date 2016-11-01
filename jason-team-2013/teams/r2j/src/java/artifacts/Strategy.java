// CArtAgO artifact code for project smadasMAPC2013

package artifacts;

import cartago.*;

public class Strategy extends Artifact {
	
	//numero estrategia
	//round
	//localizacao
	//TODO criar artefato para inspetores compartilhar inspecoes, coach tambem pode acessar
	
	
	void init(int initialValue) {
		defineObsProperty("count", initialValue);
	}
	
	@OPERATION
	void inc() {
		ObsProperty prop = getObsProperty("count");
		prop.updateValue(prop.intValue()+1);
		signal("tick");
	}
}

