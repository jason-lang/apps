package arch;

import jason.JasonException;
import jason.RevisionFailedException;
import jason.asSemantics.ActionExec;
import jason.asSyntax.Literal;
import jason.mas2j.ClassParameters;
import jason.runtime.Settings;

import java.util.ArrayList;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;
import java.util.logging.Logger;

/** 
 * 
 * Jason agent architecture customisation 
 * (it links the AgentSpeak interpreter to the contest simulator)
 * 
 * @author Jomi
 *
 */
public class ACArchitecture extends CowboyArch {

    public static final int   actionTimeout = 1500; // timeout to send an action
    
    private Logger logger;  

    private ACProxy       proxy;
    private List<Literal> percepts = new ArrayList<Literal>();
    private WaitSleep     waitSleepThread;
    
    @Override
    public void initAg(String agClass, ClassParameters bbPars, String asSrc, Settings stts) throws JasonException {
        super.initAg(agClass, bbPars, asSrc, stts);
        logger = Logger.getLogger(ACArchitecture.class.getName()+"."+getAgName());

        String username = stts.getUserParameter("username");
        if (username.startsWith("\"")) username = username.substring(1,username.length()-1);
        String password = stts.getUserParameter("password");
        if (password.startsWith("\"")) password = password.substring(1,password.length()-1);
        
        waitSleepThread = new WaitSleep();
        waitSleepThread.start();

        proxy = new ACProxy(    this, 
                                stts.getUserParameter("host"), 
                                Integer.parseInt(stts.getUserParameter("port")),
                                username,
                                password);
        new Thread(proxy,"AgentProxy"+username).start();
    }

    
    @Override
    public void stopAg() {
        super.stopAg();
        proxy.finish();
        waitSleepThread.interrupt();
    }
    
    @Override
    public List<Literal> perceive() {
        agDidPerceive(); // for crash control
        return new ArrayList<Literal>(percepts); // it must be a copy!
    }

    @Override
    /** when the agent can sleep, i.e. has nothing else to decide, sent its last action to the simulator */ 
    public void sleep() {
        waitSleepThread.go();
        super.sleep();
    }
    
    public void startNextStep(int step, List<Literal> p) {
        percepts = p;
        waitSleepThread.newCycle();
        getTS().getUserAgArch().getArchInfraTier().wake();
        setSimStep(step);
    }
    
    /** all actions block its intention and succeed in the end of the cycle, 
     *  only the last action of the cycle will be sent to simulator */ 
    @Override
    public void act(ActionExec act, List<ActionExec> feedback) {
        if (act.getActionTerm().getFunctor().equals("do")) {
            waitSleepThread.addAction(act);
        } else {
            logger.info("ignoring action "+act+", it is not a 'do'.");
        }
    }

    @Override
    void simulationEndPerceived(String result) throws RevisionFailedException {
        percepts = new ArrayList<Literal>();
        super.simulationEndPerceived(result);
    }

    // TODO: create a new agent and plug it on the connection
    
    /** this method is called when the agent crashes and other approaches to fix it (fix1 and fix2) does not worked */
    /*
    @Override
    protected boolean fix3() throws Exception {
        getTS().getLogger().warning("Cloning!");
        
        RuntimeServicesInfraTier services = getArchInfraTier().getRuntimeServices();

        // really stops the agent (since stop can block, use a thread to run it)
        new Thread() {   public void run() {
            getArchInfraTier().stopAg();
        }}.start();
        
        // create a new overall agent (arch, thread, etc.)
        ChangeArchFixer arch = (ChangeArchFixer)services.clone(getTS().getAg(), this.getClass().getName(), getTS().getUserAgArch().getAgName()+"_clone");
        arch.processParameters();
        arch.createCheckThread();
        arch.getTS().getC().create(); // use a new C.
        
        //arch.getTS().getLogger().info("Cloned!");
        
        // just to test, add !start
        arch.getTS().getC().addAchvGoal(Literal.parseLiteral("start"), Intention.EmptyInt);
        return false;
    }
     */
    
    class WaitSleep extends Thread {
        
        ActionExec        lastAction;
        String            lastActionInCurrentCycle;
        Queue<ActionExec> toExecute = new ConcurrentLinkedQueue<ActionExec>();
        Lock              lock = new ReentrantLock();
        Condition         cycle = lock.newCondition();
        long              timestartcycle = 0;
        long              timeLastAction = 0;
        int               cycleCounter = 0;
        
        
        WaitSleep() {
            super("WaitSpeepToSendAction");
        }
        
        void addAction(ActionExec action) {
            lock.lock();
            try {
                if (lastAction != null)
                    toExecute.offer(lastAction);
                lastAction = action;
            } finally {
                lock.unlock();
            }
        }
        
        void newCycle() {
            cycleCounter++;
            if (getSimStep() == 1) cycleCounter = 1;
            
            StringBuilder notsent = new StringBuilder();
            if (toExecute.size() > 1) {
                notsent.append(" The following was not sent: ");
            }
            // set all actions as successfully executed
            List<ActionExec> feedback = getTS().getC().getFeedbackActions();
            synchronized (feedback) {
                while (!toExecute.isEmpty()) {
                    ActionExec action = toExecute.poll();
                    action.setResult(true);
                    feedback.add(action);
                    if (!toExecute.isEmpty())
                        notsent.append(action.getActionTerm()+" ");
                }                
            }
            go(); // reset the wait
            
            // prepare msg to print out
            String w = "";
            if (lastActionInCurrentCycle == null && cycleCounter > 10) { // ignore problem in the first cycles (the agent is still in setup!)
                addRestart();
                w = "*** ";
            }
            
            String timetoact = ". ";
            if (lastActionInCurrentCycle != null && timestartcycle > 0) {
                timetoact = " (act in "+ (timeLastAction -  timestartcycle) +" ms)";
            }
            timestartcycle = System.currentTimeMillis();

            logger.info(w+"Last sent action was "+lastActionInCurrentCycle+" for cycle "+getSimStep()+ timetoact + notsent);            
            setLastAct(lastActionInCurrentCycle);
            lastActionInCurrentCycle = null;
        }
        
        void go() {
            lock.lock();
            try {
                cycle.signal();
            } finally {
                lock.unlock();
            }
        }
        
        boolean waitSleep() throws InterruptedException {
            lock.lock();
            try {
                return !cycle.await(actionTimeout, TimeUnit.MILLISECONDS);
            } finally {
                lock.unlock();
            }
        }
        
        @Override
        public void run() {
            while (true) {
                try {
                    lastAction = null;
                    waitSleep();
                    
                    if (lastAction != null) {
                        lastActionInCurrentCycle = lastAction.getActionTerm().getTerm(0).toString();
                        proxy.sendAction(lastActionInCurrentCycle);
                        toExecute.offer(lastAction);
                        timeLastAction = System.currentTimeMillis();
                    }
                } catch (InterruptedException e) {
                    return; // condition to stop the thread 
                } catch (Exception e) {
                    logger.log(Level.SEVERE, "Error sending "+lastAction+" to simulator.",e);
                    toExecute.clear();
                }
            }
        }
    }

}
