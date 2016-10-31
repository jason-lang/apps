// simple agent that sends messages to snooper

package tweb;


import jade.core.AID;
import jade.core.Agent;
import jade.lang.acl.ACLMessage;


/**
 * This agent is to be used in a JSP page.
 */
public class Sender extends Agent {
    
    int i = 0;
    
    public Sender() {
        // Create the message to send to the client
        System.out.println("Sender created");
    }

    public void setup() {
        addBehaviour(new jade.core.behaviours.TickerBehaviour(this,1000) {
            @Override
            protected void onTick() {
                if (i < 5) {
                    ACLMessage m = new ACLMessage(ACLMessage.INFORM);
                    m.addReceiver(new AID("snooper",AID.ISLOCALNAME));
                    m.setContent("hello "+(i++));
                    send(m);
                }
            }                
        });
    }
}




