package testbed.participants;

/**
 * Main class for the agent in the competition, it setups the source code 
 * of the agent.
 * 
 * @author hubner
 */
public class JasonDemo extends JasonARTWrapper {

	@Override
	public void initializeAgent() {
	    super.initializeAgent("src/testbed/participants/demo.asl", true);
	}
}
