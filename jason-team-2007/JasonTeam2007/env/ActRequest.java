package env;

import jason.asSemantics.ActionExec;
import arch.LocalMinerArch;

class ActRequest {
	LocalMinerArch   ag;
	ActionExec  action;
	ActRequest(LocalMinerArch ag, ActionExec action) {
		this.ag = ag;
		this.action = action;
	}
}
