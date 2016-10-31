package arch;

import jason.JasonException;
import jason.architecture.AgArch;
import jason.asSemantics.Message;
import jason.asSyntax.Atom;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.PredicateIndicator;
import jason.environment.grid.Location;
import jason.mas2j.ClassParameters;
import jason.runtime.Settings;

import java.io.PrintWriter;
import java.util.Iterator;
import java.util.logging.Logger;

import env.MiningEnvironment;
import env.WorldModel;
import env.WorldView;

/** Common arch for local and contest architectures */
public class MinerArch extends AgArch {

	WorldModel model = null;
	WorldView  view  = null;
	
	String     simId = null;
	int	       myId  = -1;
	boolean    gui   = false;
	boolean    running = true;
	boolean    playing = false;
	
	int        cycle  = 0;
	
	WriteModelThread writeModelT = null;
	private Logger logger = Logger.getLogger(MinerArch.class.getName());

	
	@Override
    public void initAg(String agClass, ClassParameters bbPars, String asSrc, Settings stts) throws JasonException {
		super.initAg(agClass, bbPars, asSrc, stts);
	    gui = "yes".equals(stts.getUserParameter("gui"));
	    if ("yes".equals(stts.getUserParameter("write_model"))) {
        	writeModelT = new WriteModelThread();
        	writeModelT.start();
        }
	}
	
	@Override
	public void stopAg() {
		running = false;
		if (view != null) {
			view.dispose();
		}
		super.stopAg();
	}
	
    void setSimId(String id) {
        simId = id;
    }

	public int getMyId() {
		if (myId < 0) {
			myId = Integer.parseInt(getAgName().substring(5)) - 1;
		}
		return myId;
	}

	public WorldModel getModel() {
		return model;
	}

    /** The perception of the grid size is removed from the perceptions list 
        and "directly" added as a belief */
    void gsizePerceived(int w, int h) {
		if (view != null) {
			view.dispose();
		}
        model = new WorldModel(w, h);
        if (gui) {
        	view = new WorldView("Mining (view of miner "+(getMyId()+1)+")",model);
        }
        getTS().getAg().addBel(Literal.parseLiteral("gsize("+simId+","+w+","+h+")"));
        playing = true;
    }
    
    /** The perception of the depot location is removed from the perceptions list 
        and "directly" added as a belief */
    void depotPerceived(int x, int y) {
        model.setDepot(x, y);
        getTS().getAg().addBel(Literal.parseLiteral("depot("+simId+","+x+","+y+")"));
    }

    /** The number of steps of the simulation is removed from the perceptions list 
        and "directly" added as a belief */
    void stepsPerceived(int s) {
    	getTS().getAg().addBel(Literal.parseLiteral("steps("+simId+","+s+")"));
        model.setSteps(s);
    }
    
	/** udpate the model with obstacle and share them with the teamates */
	void obstaclePerceived(int x, int y, Literal p) {
		if (! model.hasObject(WorldModel.OBSTACLE, x, y)) {
			model.add(WorldModel.OBSTACLE, x, y);
			
			Message m = new Message("tell", null, null, p);
			try {
				broadcast(m);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}		
	}

    Location lo1 = new Location(-1,-1), // last locations of the agent 
             lo2 = new Location(-1,-1), 
             lo3 = new Location(-1,-1), 
             lo4 = new Location(-1,-1),
             lo5 = new Location(-1,-1),
             lo6 = new Location(-1,-1);

	
	/** udpate the model with the agent location and share this information with teammates */
	void locationPerceived(int x, int y) {
		Location oldLoc = model.getAgPos(getMyId());
        if (oldLoc != null) {
            model.clearAgView(oldLoc); // clear golds and  enemies
        }
		if (oldLoc == null || !oldLoc.equals(new Location(x,y))) {
			try {
				model.setAgPos(getMyId(), x, y);
				model.incVisited(x, y);
			
				Message m = new Message("tell", null, null, "my_status("+x+","+y+","+model.getGoldsWithAg(getMyId())+")");
				broadcast(m);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
        lo6 = lo5;
        lo5 = lo4;
        lo4 = lo3;
        lo3 = lo2;
        lo2 = lo1;
        lo1 = new Location(x,y);

        if (isRobotFrozen()) {
        	try {
	        	//logger.info("** Arch adding restart for "+getAgName()+", TS="+getTS().getCurrentTask()+", "+getTS().getC());
	        	getTS().getC().create();
        		
	        	getTS().getAg().getBB().abolish(new Atom("restart").getPredicateIndicator());
	        	getTS().getAg().getBB().abolish(new PredicateIndicator("gold",2)); // tira os ouros
	        	getTS().getAg().addBel(new Atom("restart"));
	        	lo2 = new Location(-1,-1); // to not restart again in the next cycle
	     
	        	//getTS().stopCycle();
        	} catch (Exception e) {
            	logger.info("Error in restart!"+ e);
        	}
        }
	}
	
	/** returns true if the agent do not move in the last 5 location perception */
	public boolean isRobotFrozen() {
		return lo1.equals(lo2) && lo2.equals(lo3) && lo3.equals(lo4) && lo4.equals(lo5) && lo5.equals(lo6);
	}
	
    /** update the number of golds the agent is carrying */
    void carriedGoldsPerceived(int n) {
        model.setGoldsWithAg(getMyId(), n);
    }
    
    void goldPerceived(int x, int y) {
    	model.add(WorldModel.GOLD, x, y);
    }

    // not used, the allies send messages with their location    
    //void allyPerceived(int x, int y) {
    //    model.add(WorldModel.AGENT, x, y);
    //}
    
    void enemyPerceived(int x, int y) {
        model.add(WorldModel.ENEMY, x, y); 
    }

    void simulationEndPerceived(String result) {
    	getTS().getAg().addBel(Literal.parseLiteral("end_of_simulation("+simId+","+result+")"));
        playing = false;
    }
	
    void setCycle(int s) {
    	cycle = s;
		if (view != null) view.setCycle(cycle);
        //if (writeModelT != null) writeModelT.writeModel();
    }
    
	@Override
    public void checkMail() {
		super.checkMail();

		// remove messages related to obstacles and agent_position
		// and update the model
		Iterator<Message> im = getTS().getC().getMailBox().iterator();
		while (im.hasNext()) {
			Message m  = im.next();
			String  ms = m.getPropCont().toString();
			if (ms.startsWith("cell") && ms.endsWith("obstacle)") && model != null) {
				Literal p = (Literal)m.getPropCont();
				int x = (int)((NumberTerm)p.getTerm(0)).solve();
				int y = (int)((NumberTerm)p.getTerm(1)).solve();
				if (model.inGrid(x,y)) {
					model.add(WorldModel.OBSTACLE, x, y);
				}
				im.remove();
				//getTS().getAg().getLogger().info("received obs="+p);
				
			} else if (ms.startsWith("my_status") && model != null) {
				// update others location
				Literal p = Literal.parseLiteral(m.getPropCont().toString());
				int x = (int)((NumberTerm)p.getTerm(0)).solve();
				int y = (int)((NumberTerm)p.getTerm(1)).solve();
				if (model.inGrid(x,y)) {
					int g = (int)((NumberTerm)p.getTerm(2)).solve();
					try {
						int agid = MiningEnvironment.getAgId(m.getSender());
						model.setAgPos(agid, x, y);
						model.setGoldsWithAg(agid, g);
						model.incVisited(x, y);
						//getTS().getAg().getLogger().info("ag pos "+getMinerId(m.getSender())+" = "+x+","+y);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
				im.remove(); 
			}
		}
    }
	
	class WriteModelThread extends Thread {
		public void run() {
			String fileName = "world-state-"+getAgName()+".txt";
			try {
				PrintWriter out = new PrintWriter(fileName);
				while (running) {
					waitSomeTime();
					if (model != null && playing) {
						out.println("\n\n** Agent "+getAgName()+" in cycle "+cycle+"\n");
						for (int i=0; i<model.getNbOfAgs(); i++) {
							out.println("miner"+(i+1)+" is carrying "+model.getGoldsWithAg(i)+" gold(s), at "+model.getAgPos(i));
						}
						out.println(model.toString());
						out.flush();
					}
				}
				out.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		synchronized private void waitSomeTime() throws InterruptedException {
			wait(2000);
		}
	}
}
