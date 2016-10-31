import cartago.Artifact;
import cartago.OPERATION;
import cartago.ObsProperty;

/**
 *      Artifact simulating the appearance of manufacturing orders, generated at random intervals. 
 */
public class rotTable extends Artifact {
    
    @OPERATION public void init()  {
        // observable properties   
        defineObsProperty("jig_loader", "empty");
		defineObsProperty("jig_joiner", "empty");
    }

    @OPERATION void table_rotated() {
		ObsProperty jig1 = getObsProperty("jig_loader");
		ObsProperty jig2 = getObsProperty("jig_joiner");
		String s = new String(jig1.stringValue());
		jig1.updateValue(jig2.stringValue());
		jig2.updateValue(s);
		System.out.println("************ rotating... now "+
		jig1.toString()+" and "+jig2.toString());
    }

    @OPERATION void reserve_jig(String S) {
		if (!(getObsProperty("jig_loader").stringValue().equals("empty"))) {
			System.out.println("WRONG: Can only reserve an empty jig!");
			failed("Can only reserve an empty jig!");
		}
		getObsProperty("jig_loader").updateValue("reserved");
		System.out.println("************ "+getObsProperty("jig_loader").toString()+" Scheme "+S);
	}

    @OPERATION void a_loaded() {
		if (!(getObsProperty("jig_loader").stringValue().equals("empty")) &&
		    !(getObsProperty("jig_loader").stringValue().equals("reserved"))) {
			System.out.println("WRONG: Jig should be empty to start with!");
			failed("Jig should be empty to start with!");
		}
		getObsProperty("jig_loader").updateValue("a");
		System.out.println("************ "+getObsProperty("jig_loader").toString());
	}

    @OPERATION void b_loaded() {
		if (!(getObsProperty("jig_loader").stringValue().equals("a"))) {
			System.out.println("WRONG: Part A should be already there!");
			failed("Part A should be already there!");
		}
		getObsProperty("jig_loader").updateValue("ab");
		System.out.println("************ "+getObsProperty("jig_loader").toString());
    }
    
    @OPERATION void c_loaded() {
		if (!(getObsProperty("jig_loader").stringValue().equals("flipping"))) {
			System.out.println("WRONG: Jig should be empty while flipping!");
			failed("Jig should be empty while flipping!");
		}
		getObsProperty("jig_loader").updateValue("c");
		System.out.println("************ "+getObsProperty("jig_loader").toString());
    }

    @OPERATION void ab_moved_to_flipper() {
		if (!(getObsProperty("jig_loader").stringValue().equals("[ab]"))) {
			System.out.println("WRONG: Joined AB part should be already there!");
			failed("Joined AB part should be already there!");
		}
		getObsProperty("jig_loader").updateValue("flipping");
		System.out.println("************ "+getObsProperty("jig_loader").toString());
    }

    @OPERATION void flipped_to_ba() {
		System.out.println("************ flipping...");
    }

    @OPERATION void ba_loaded_ontopof_c() {
		if (!(getObsProperty("jig_loader").stringValue().equals("c"))) {
			System.out.println("WRONG: Part C should be already there!");
			failed("Part C should be already there!");
		}
		getObsProperty("jig_loader").updateValue("c[ba]");
		System.out.println("************ "+getObsProperty("jig_loader").toString());
    }

    @OPERATION void part_unloaded() {
		if (!(getObsProperty("jig_loader").stringValue().equals("[cba]"))) {
			System.out.println("WRONG: Need a complete part [CBA] loaded to unload it!");
			failed("Need a complete part [CBA] loaded to unload it!");
		}
		getObsProperty("jig_loader").updateValue("empty");
		System.out.println("************ "+getObsProperty("jig_loader").toString());
    }

    @OPERATION void ab_joined() {
		if (!(getObsProperty("jig_joiner").stringValue().equals("ab"))) {
			System.out.println("WRONG: I need parts A and B loaded to join them!");
			failed("I need parts A and B loaded to join them!");
		}
		getObsProperty("jig_joiner").updateValue("[ab]");
		System.out.println("************ "+getObsProperty("jig_joiner").toString());
    }

    @OPERATION void abc_joined() {
		if (!(getObsProperty("jig_joiner").stringValue().equals("c[ba]"))) {
			System.out.println("WRONG: I need parts C and [BA] loaded to join them!");
			failed("I need parts C and [BA] loaded to join them!");
		}
		getObsProperty("jig_joiner").updateValue("[cba]");
		System.out.println("************ "+getObsProperty("jig_joiner").toString());
    }
}

