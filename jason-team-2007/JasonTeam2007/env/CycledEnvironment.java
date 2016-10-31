package env;

import jason.asSemantics.ActionExec;
import jason.asSyntax.Structure;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Logger;

import arch.LocalMinerArch;

/**
 * A version of the environment based on cycles. Each agent perform an action each
 * cycle. When all agents sent their action or some timeout has passed, 
 * the next cycle starts.
 * 
 * @author jomi
 */
public abstract class CycledEnvironment extends jason.environment.Environment {

    private static Logger logger   = Logger.getLogger("jasonTeamSimLocal.mas2j." + CycledEnvironment.class.getName());

    protected int 			  cycle      = 0; // cycle number
	private   ActRequest[]    finished; // the agents that did an action in the current cycle
    private   ExecutorService executor; // the thread pool used to execute actions
    private   int             sleep; // mili seconds after each cycle
    private   int             cycleTime; // seconds of each cycle
    
	public void init(int nbOfAgents, int nbOfThreads, int sleep, int cycleTime) {
        this.sleep = sleep;
        this.cycleTime = cycleTime;
        finished = new ActRequest[nbOfAgents];
        executor = Executors.newFixedThreadPool(nbOfThreads);
        startNextCycle();
    }
	
    protected void setCycle(int c) {
        cycle = c;
    }
    
    public void setSleep(int s) {
        sleep = s;
    }	

    @Override
	public void stop() {
		super.stop();
        executor.shutdownNow();
	}

	private long initSimTime    = 0;    
    private long lastCycleStart = System.currentTimeMillis();
    private long longestCycle   = -1;
    
    protected void startNextCycle() {    	
		synchronized (finished) {
			cycle++;
			for (int i=0; i<finished.length; i++) finished[i] = null;
		}

		long now  = System.currentTimeMillis();
		long time = (now-lastCycleStart);
		lastCycleStart = now;
		if (cycle == 1) initSimTime = now;
		long mean = (now - initSimTime) / cycle;
		if ((longestCycle == -1 || time > longestCycle) && cycle > 10) longestCycle = time;
		
		logger.info("Cycle "+cycle+" (previous cycle take "+time+" mili-seconds, mean is "+mean+", max is "+longestCycle+")");
		
		// create a thread to wait cycle timeout
		new Thread() {
			synchronized public void run() {
				int prevCycle = cycle;
				try {
					wait(cycleTime * 1000);
					// if cycle do not change, start the next
					if (prevCycle == cycle && getEnvironmentInfraTier().isRunning()) {
                        String who = "";
                        for (int i=0; i<finished.length; i++) { 
                            if (finished[i] == null) {
                                who += (i+1);
                            }
                        }
						logger.info("Cycle "+cycle+" finished by timeout! Agents that do not finish: "+who);
						finishCycle();
					}
				} catch (InterruptedException e) {}
			}
		}.start();

    }    

	protected void finishCycle() {
        if (sleep > 0) {
            try {
				Thread.sleep(sleep);
			} catch (InterruptedException e) {}
        }
		ActRequest[] fclone = null;
		synchronized (finished) {
			fclone = finished.clone();
			startNextCycle();
			
			//logger.info("Actions order = "+order);
			//order = new StringBuilder();	        
		}
		cycleFinished(fclone);
	}

	abstract void cycleFinished(ActRequest[] acts);
	abstract int  getAgNbFromName(String name);

	/** this method is called by the agents to request some action performance */
    public void addActionInSchedule(final LocalMinerArch ag, final ActionExec act) {
		synchronized (finished) {
			if (finished[getAgNbFromName(ag.getAgName())] != null) { // the agent already did an action in this cycle
				logger.warning("** Agent "+ag.getAgName()+" is trying two action is the same cycle! This action was ignored.");
			} else {
                executor.execute(new Runnable() {
                    public void run() {
                        Structure acTerm = act.getActionTerm();
                        if (executeAction(ag.getAgName(), acTerm)) {
                            act.setResult(true);
                        } else {
                            act.setResult(false);
                        }
    
                        addExecutedAction(new ActRequest(ag,act));
                    };
                });
			}
		}
    }

    
    //StringBuilder order = new StringBuilder();
    
    /** this method is called by the pool when some action was executed in the environment */
	private void addExecutedAction(ActRequest req) {
		boolean all = true;
		synchronized (finished) {
	
			finished[getAgNbFromName(req.ag.getAgName())] = req;
			
			//order.append(req.ag.getAgName());
			//order.append(" ");
			
			for (int i=0; i<finished.length; i++) { 
				if (finished[i] == null) {
					all = false;
					break;
				}
			}
			
		}
        if (all) { // all agents act in this cicle
        	finishCycle();
        }	        
	}
}
