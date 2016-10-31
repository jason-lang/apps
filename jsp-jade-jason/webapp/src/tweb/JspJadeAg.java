// agent that interacts with the JSP page

package tweb;

import jade.core.Agent;

/**
 * This agent is to be used in a JSP page.
 */
public class JspJadeAg extends Agent {
    public void setup() {
        System.out.println("Init agent setup");
        ((tweb.JadeBridge)getArguments()[0]).ag = this;
        System.out.println("Setup done!");
    }
}
