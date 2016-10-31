package arch;

import jason.JasonException;
import jason.asSyntax.Literal;
import jason.mas2j.ClassParameters;
import jason.runtime.Settings;

import java.util.List;

import jmoise.OrgAgent;

/** 
 *  An agent architecture that try to identify a crashed agent and then try to fix it.
 * 
 *  @author Jomi
 */
public class IdentifyCrashed extends OrgAgent {

    private boolean didPercept = true;
    private int     maxCycleTime = 4000;
    private boolean dead = false;
    private Thread  agThread = null;
    private Thread  checkThread = null;
    
    @Override
    public void initAg(String agClass, ClassParameters bbPars, String asSrc, Settings stts) throws JasonException {
        super.initAg(agClass, bbPars, asSrc, stts);
        processParameters();
        createCheckThread();
    }

    void processParameters() {
        String arg = getTS().getSettings().getUserParameter("maxCycleTime");
        if (arg != null) 
            maxCycleTime = Integer.parseInt(arg);        
    }
    
    void createCheckThread() {
        // creates a thread that check if the agent is dead
        checkThread = new TestDead();
        checkThread.start();
    }
    
    @Override
    public List<Literal> perceive() {
        agThread = Thread.currentThread();
        agDidPerceive();
        return super.perceive();
    }
    
    public synchronized void agDidPerceive() {
        didPercept = true;
        notifyAll();
    }
    
    private synchronized void waitPerceive() throws InterruptedException {
        wait(maxCycleTime);
    }

    public boolean isCrashed() {
        return !didPercept;
    }

    @Override
    public void stopAg() {
        checkThread.interrupt();
        super.stopAg();
    }
    
    /** try to fix the agent: approach 1: simulates the agent has stopped */
    protected boolean fix1() throws Exception {
        getTS().getLogger().warning("fix1: I am dead! Simulating a termination...");
        
        // simulates a stop running
        dead = true;

        // gives some time to TS get the change in state
        waitPerceive();
        try {
            if (isCrashed()) {
                return fix2();
            } else {
                getTS().getLogger().warning("fix1: I am Ok now!");
                return true;
            }
        } finally {
            // start the agent again
            dead = false;
        }
    }

    /** try to fix the agent: approach 2: interrupt the agent thread */
    protected boolean fix2() throws Exception {
        if (agThread != null) {
            getTS().getLogger().warning("fix2: I am still dead! Interrupting the agent thread...");
            // try to interrupt the agent thread.
            
            agThread.interrupt();
        
            waitPerceive();
            if (isCrashed()) {
                getTS().getLogger().warning("Interrupt doesn't work!!! The agent remains dead!");
                return fix3();
            } else {
                getTS().getLogger().warning("fix2: I am Ok now!");
                return true;
            }
        } else {
            getTS().getLogger().warning("fix2: can not be used (thread == null).");
            return fix3();            
        }
    }
    
    /** try to fix the agent: approach 3: user defined */
    protected boolean fix3() throws Exception {
        return false;
    }    
    
    @Override
    public boolean isRunning() {
        return !dead && super.isRunning();
    }
    
    class TestDead extends Thread {
        public TestDead() {
            super("TestDeadAg-"+getAgName());
        }
        @Override
        public void run() {
            try {
                sleep(maxCycleTime*2); // wait a bit before start checking
                while (IdentifyCrashed.super.isRunning()) {
                    didPercept = false;
                    sleep(maxCycleTime);
                    if (isCrashed()) {
                        // agent is dead!
                        fix1();                        
                    }
                }
            } catch (Exception e) {} // no problem the agent should stop running, simply quite the thread 
        }
    }
}
