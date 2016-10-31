package testbed.participants;

/**
 * Main class for the agent in the competition, it setups the source code 
 * of the agent.
 * 
 * @author hubner
 */
public class ForTrust extends JasonARTWrapper {

	@Override
	public void initializeAgent() {
	    super.initializeAgent("src/testbed/participants/fortrust-ag.asl", true); // true/false -> mind dump
	}
}
