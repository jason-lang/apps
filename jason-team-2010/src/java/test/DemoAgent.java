package test;

import org.w3c.dom.Element;

public class DemoAgent extends AbstractAgent {

    // main: should create new instance and configure it.
    public static void main(String[] args) {
        DemoAgent agent = new DemoAgent();
        // configure network
        agent.setPort(12300);
        agent.setHost("localhost");

        // configure credentials
        agent.setUsername(args[0]);
        agent.setPassword(args[1]);

        // launch agent
        agent.start();
    }

    public void processLogIn() {
        System.out.println("Login Ok");
        
        new Thread() { public void run() {
            int i = 0;
            while (true) {
               
                try {
                    sleep(1000);
                    System.out.println("send ping "+i);
                    sendPing("test"+i);
                    i++;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };}.start();
    }

    public void processPong(String pong) {
        System.out.println("Rec Pong "+pong);
    }

    public void processSimulationEnd(Element perception, long currenttime) {
    }

    public void processSimulationStart(Element perception, long currenttime) {
        System.out.println("Start!");
    }

    public void processRequestAction(Element perception, Element target,  long currenttime, long deadline) {
        System.out.println("Action request");
    }

}
