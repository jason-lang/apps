// agent that interacts with the JSP page

package tweb;


import jade.core.Agent;
import jade.lang.acl.ACLMessage;

import java.util.List;

/**
 * This agent is to be used in a JSP page.
 */
public class Snooper extends Agent {
    public Snooper() {
        // Create the message to send to the client
        System.out.println("Snooper created");
    }

    public void setup() {
        @SuppressWarnings("unchecked")
        final List<ACLMessage> l = (List<ACLMessage>)getArguments()[0];
        addBehaviour(new jade.core.behaviours.CyclicBehaviour() {          
            public void action() {
                System.out.println(" Trying... ");
                ACLMessage m = receive();
                if(m != null) {
                    System.out.println(" received "+m);
                    l.add(m);
                } else { 
                    block();
                }
            }
        });
    }
}




