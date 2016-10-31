import jade.core.AID;
import jade.core.Agent;
import jade.core.behaviours.CyclicBehaviour;
import jade.core.behaviours.OneShotBehaviour;
import jade.lang.acl.ACLMessage;

public class JadeAgentTest extends Agent {

    @Override
    protected void setup() {
        addBehaviour(new OneShotBehaviour() {            
            @Override
            public void action() {
                // send a message to agent a
                ACLMessage m = new ACLMessage(ACLMessage.INFORM);
                m.setContent("hello");
                m.addReceiver(new AID("a", AID.ISLOCALNAME));
                send(m);
                System.out.println("message sent "+m);
            }
        });
        
        addBehaviour(new CyclicBehaviour() {
            
            @Override
            public void action() {
                try {
                    ACLMessage m = receive();
                    if (m != null) {
                        System.out.println("received "+m.getContent());
                    }
                } catch (Exception e) {
                    System.out.println(e);
                }
            }
        });
    }
}
