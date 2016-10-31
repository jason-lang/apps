package arch;

import static jason.asSyntax.ASSyntax.createLiteral;
import static jason.asSyntax.ASSyntax.createNumber;
import jason.JasonException;
import jason.ReceiverNotFoundException;
import jason.RevisionFailedException;
import jason.asSemantics.Intention;
import jason.asSemantics.Message;
import jason.asSyntax.Atom;
import jason.asSyntax.Literal;
import jason.asSyntax.LiteralImpl;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jason.environment.grid.Location;
import jason.mas2j.ClassParameters;
import jason.runtime.Settings;

import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

import agent.SelectEvent;
import env.ACViewer;
import env.WorldModel;
import env.WorldView;

/** 
 *  Common arch for both local and contest architectures.
 *  
 *   @author Jomi
 */
public class CowboyArch extends IdentifyCrashed { 

    LocalWorldModel model = null;
    WorldView       view  = null;
    
    String     simId = null;
    int        myId  = -1;
    boolean    gui   = false;
    boolean    playing = false;
    
    String   massimBackDir = null;
    ACViewer acView        = null;
    
    int        simStep  = 0;
    
    WriteStatusThread writeStatusThread = null;
    
    protected Logger logger = Logger.getLogger(CowboyArch.class.getName());

    public static Atom aOBSTACLE    = new Atom("obstacle");
    public static Atom aENEMY       = new Atom("enemy");
    public static Atom aENEMYCORRAL = new Atom("enemycorral");
    public static Atom aALLY        = new Atom("ally");
    public static Atom aEMPTY       = new Atom("empty");
    
    
    @Override
    public void initAg(String agClass, ClassParameters bbPars, String asSrc, Settings stts) throws JasonException {
        super.initAg(agClass, bbPars, asSrc, stts);
        model = new LocalWorldModel(10,10, WorldModel.agsByTeam, getTS().getAg().getBB()); // just to have a default model
        gui = "yes".equals(stts.getUserParameter("gui"));
        if ("yes".equals(stts.getUserParameter("write_status"))) {
            writeStatusThread = WriteStatusThread.create(this);
        }
        WriteStatusThread.registerAgent(getAgName(), this);
        
        // create the viewer for contest simulator
        massimBackDir = stts.getUserParameter("ac_sim_back_dir");
        if (massimBackDir != null && massimBackDir.startsWith("\"")) 
            massimBackDir = massimBackDir.substring(1,massimBackDir.length()-1);
        logger = Logger.getLogger(CowboyArch.class.getName() + ".CA-" + getAgName());
        
        setCheckCommunicationLink(false);
	}
	
	@Override
	public void stopAg() {
		if (view != null)   view.dispose();
		if (acView != null) acView.finish();
		if (writeStatusThread != null) writeStatusThread.interrupt();
		super.stopAg();
	}

	@Override
	public boolean isCrashed() {
	    return playing && super.isCrashed();
	}
	
    void setSimId(String id) {
        simId = id;
    }

    public boolean hasGUI() {
    	return gui;
    }
    
	public int getMyId() {
		if (myId < 0) {
			myId = getAgId(getAgName());
		}
		return myId;
	}

	public LocalWorldModel getModel() {
		return model;
	}
	
	public ACViewer getACViewer() {
	    return acView;
	}

    /** The perception of the grid size is removed from the percepts list 
        and "directly" added as a belief */
    void gsizePerceived(int w, int h, String opponent) throws RevisionFailedException {
        model = new LocalWorldModel(w, h, WorldModel.agsByTeam, getTS().getAg().getBB());
        getTS().getAg().addBel(Literal.parseLiteral("gsize("+w+","+h+")"));
        playing = true;

        // manage GUIs
        if (view != null)   view.dispose();
        if (acView != null) acView.finish();
        if (gui) view = new WorldView("Herding (view of cowboy "+(getMyId()+1)+") -- against "+opponent,model);
        if (writeStatusThread != null)  writeStatusThread.reset();

        if (massimBackDir != null && massimBackDir.length() > 0) { 
            acView = new ACViewer(massimBackDir, w, h);
            acView.setPriority(Thread.MIN_PRIORITY);
            acView.start();
        }
    }
    
    /** The perception of the corral location is removed from the percepts list 
        and "directly" added as a belief */
    void corralPerceived(Location upperLeft, Location downRight) throws RevisionFailedException  {
        model.setCorral(upperLeft, downRight);
        if (acView != null) acView.getModel().setCorral(upperLeft, downRight);
        getTS().getAg().addBel(Literal.parseLiteral("corral("+upperLeft.x+","+upperLeft.y+","+downRight.x+","+downRight.y+")"));
    }

    /** The number of steps of the simulation is removed from the percepts list 
        and "directly" added as a belief */
    void stepsPerceived(int s) throws RevisionFailedException {
    	getTS().getAg().addBel(Literal.parseLiteral("steps("+s+")"));
        model.setMaxSteps(s);
    }

	/** update the model with obstacle and share them with the team mates */
	public void obstaclePerceived(int x, int y, Literal p) {
		if (! model.hasObject(WorldModel.OBSTACLE, x, y)) {
			model.add(WorldModel.OBSTACLE, x, y);
			if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);
			Message m = new Message("tell", null, null, p);
			try {
				broadcast(m);
			} catch (Exception e) {	e.printStackTrace(); }
		}		
	}

	public void enemyCorralPerceived(int x, int y, Literal p) {
		if (! model.hasObject(WorldModel.ENEMYCORRAL, x, y)) {
			model.add(WorldModel.ENEMYCORRAL, x, y);
			if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);
			Message m = new Message("tell", null, null, p);
			try {
				broadcast(m);
			} catch (Exception e) {	e.printStackTrace(); }
		}		
	}

    Location lo1 = new Location(-1,-1), // last locations of the agent 
             lo2 = new Location(-1,-1), 
             lo3 = new Location(-1,-1), 
             lo4 = new Location(-1,-1),
             lo5 = new Location(-1,-1),
             lo6 = new Location(-1,-1),
             lo7 = new Location(-1,-1);


    Location oldLoc;
    /** the location in previous cycle */
	public Location getLastLocation() {
	    return oldLoc; 
	}
	
	protected String lastAct;
	protected void setLastAct(String act) {
	    lastAct = act;
	}
	public String getLastAction() {
	    return lastAct;
	}
	
	public int getSimStep() {
	    return simStep;
	}
	
	
	/** update the model with the agent location and share this information with team mates */
	void locationPerceived(int x, int y) {
		oldLoc = model.getAgPos(getMyId());
        if (oldLoc != null) {
            model.clearAgView(oldLoc); // clear golds and  enemies
        }
		if (oldLoc == null || !oldLoc.equals(new Location(x,y))) {
			try {
				model.setAgPos(getMyId(), x, y);
				if (acView != null) acView.getModel().setAgPos(getMyId(), x, y);
				model.incVisited(x, y);
			
				Message m = new Message("tell", null, null, "my_status("+x+","+y+")");
				broadcast(m);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		lo7 = lo6;
        lo6 = lo5;
        lo5 = lo4;
        lo4 = lo3;
        lo3 = lo2;
        lo2 = lo1;
        lo1 = new Location(x,y);

        if (isRobotFrozen()) {
        	addRestart();
        }
	}
	
	/** returns true if the agent do not move in the last 5 location perception */
	public boolean isRobotFrozen() {
		return lo1.equals(lo2) && lo2.equals(lo3) && lo3.equals(lo4) && lo4.equals(lo5) && lo5.equals(lo6) && lo6.equals(lo7);
	}

	protected void addRestart() {
    	try {
        	logger.info("** Arch adding restart for "+getAgName());
    	    //getTS().getC().create(); // it is terrible for pending intentions of cowboys!
        	getTS().getC().addAchvGoal(new LiteralImpl("restart"), Intention.EmptyInt);
        	lo2 = new Location(-1,-1); // to not restart again in the next cycle
    	} catch (Exception e) {
        	logger.info("Error in restart!"+ e);
    	}
	}
	
    public static Literal createCellPerception(int x, int y, Term obj) {
        return createLiteral("cell", createNumber(x), createNumber(y), obj); 
    }

    void initKnownCows() {
    	model.clearCows();
    }
    
    void enemyPerceived(int x, int y) {
        model.add(WorldModel.ENEMY, x, y); 
    }

    void simulationEndPerceived(String result) throws RevisionFailedException {
    	getTS().getAg().addBel(Literal.parseLiteral("end_of_simulation("+result+")"));
    	model   = null;
        playing = false;
        if (view != null) view.dispose();
    }
	
    void setSimStep(int s) {
        ((SelectEvent)getTS().getAg()).cleanCows();
    	simStep = s;
    	super.setCycleNumber(simStep);
		if (view != null) view.setCycle(simStep);
        if (writeStatusThread != null) writeStatusThread.go();
    }
    
    void setScore(int s) {
        model.setCowsBlue(s);
    }
    
    /** change broadcast to send messages to only my team mates */
    @Override
    public void broadcast(Message m) throws Exception {
    	String basename = getAgName().substring(0,getAgName().length()-1);
    	for (int i=1; i <= model.getAgsByTeam() ; i++) {
    	    String oname = basename+i;
    		if (!getAgName().equals(oname)) {
    			Message msg = new Message(m);
    			msg.setReceiver(oname);
    			for (int t=0; t<6; t++) {
	    			try {
	    			    sendMsg(msg);
	    			    break; // the for
	    			} catch (ReceiverNotFoundException e) {
	    				// wait and try again
	    				Thread.sleep(500);
	    			}
    			}
    		}
    	}
    }
    
	@Override
	public void checkMail() {
		super.checkMail();
		
		// remove messages related to obstacles and agent_position
		// and update the model
		Iterator<Message> im = getTS().getC().getMailBox().iterator();
		while (im.hasNext()) {
			Message m  = im.next();
			try {
    			if (m.getIlForce().equals("tell-cows")) {
    				im.remove();
    				/* not used anymore
    				if (model != null) {
	    				for (Location l: (Collection<Location>)m.getPropCont()) {
	    					cowPerceived(l.x, l.y);
	    				}
    				}
    				*/
    			} else {
	    			String  ms = m.getPropCont().toString();
	    			if (ms.startsWith("cell") && ms.endsWith("obstacle)") && model != null) {
                        im.remove();

                        Literal p = (Literal)m.getPropCont();
	    				int x = (int)((NumberTerm)p.getTerm(0)).solve();
	    				int y = (int)((NumberTerm)p.getTerm(1)).solve();
	    				if (model.inGrid(x,y)) {
	    					model.add(WorldModel.OBSTACLE, x, y);
	    					if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);
	    				}
	    				//getTS().getAg().getLogger().info("received obs="+p);
	    				
	    			} else if (ms.startsWith("cell") && ms.endsWith(aENEMYCORRAL.toString()+")") && model != null) {
	                        im.remove();

	                        Literal p = (Literal)m.getPropCont();
		    				int x = (int)((NumberTerm)p.getTerm(0)).solve();
		    				int y = (int)((NumberTerm)p.getTerm(1)).solve();
		    				if (model.inGrid(x,y)) {
		    					model.add(WorldModel.ENEMYCORRAL, x, y);
		    					if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);
		    				}
		    				
	    			} else if (ms.startsWith("my_status") && model != null) {
                        im.remove(); 

                        // update others location
	    				Literal p = Literal.parseLiteral(m.getPropCont().toString());
	    				int x = (int)((NumberTerm)p.getTerm(0)).solve();
	    				int y = (int)((NumberTerm)p.getTerm(1)).solve();
	    				if (model.inGrid(x,y)) {
	    					try {
	    						int agid = getAgId(m.getSender());
	    						model.setAgPos(agid, x, y);
	    						if (acView != null) acView.getModel().setAgPos(agid, x, y);
	    						model.incVisited(x, y);
	    						//getTS().getAg().getLogger().info("ag pos "+getMinerId(m.getSender())+" = "+x+","+y);
	    						Literal tAlly = createLiteral("ally_pos", new Atom(m.getSender()), createNumber(x), createNumber(y));
	    						getTS().getAg().addBel( tAlly );
	    					} catch (Exception e) {
	    						e.printStackTrace();
	    					}
	    				}
	    			}
    			}
            } catch (Exception e) {
                logger.log(Level.SEVERE, "Error checking email!",e);
            }
		}
    }

    public static int getAgId(String agName) {
		return (Integer.parseInt(agName.substring(agName.length()-1))) - 1;    	
    }

}

