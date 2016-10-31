package cph;

import jason.asSemantics.Agent;

public class CPHAgent extends Agent {

	/** only accepts "achieve" messages from mds robots */
	public boolean acceptAchieve(String sender, String content) {
		if (sender.startsWith("mds")) {
			return true;
		} else {
			return false;
		}
	}
	
}
