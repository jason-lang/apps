package arch;

import static jason.asSyntax.ASSyntax.createAtom;
import static jason.asSyntax.ASSyntax.createLiteral;
import static jason.asSyntax.ASSyntax.createNumber;
import jason.JasonException;
import jason.ReceiverNotFoundException;
import jason.RevisionFailedException;
import jason.asSemantics.Intention;
import jason.asSemantics.Message;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Atom;
import jason.asSyntax.Literal;
import jason.asSyntax.LiteralImpl;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.environment.grid.Location;
import jason.mas2j.ClassParameters;
import jason.runtime.Settings;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

import jia.cluster;
import jmoise.OrgAgent;
import agent.SelectEvent;
import env.WorldModel;
import env.WorldView;
import env.WorldModel.Move;

/** 
 *  Common arch for both local and contest architectures.
 *  
 *   @author Jomi
 */
public class CowboyArch extends OrgAgent { //IdentifyCrashed { 

    LocalWorldModel model = null;
    WorldView       view  = null;
    
    String     simId = null;
    int        myId  = -1;
    boolean    gui   = false;
    boolean    playing = false;
    
    String   massimBackDir = null;
    //ACViewer acView        = null;
    
    String   teamId        = null;
    
    Map<Integer, Location> perceivedCows = new HashMap<Integer,Location>(); // stores the location of some cows
    Map<Integer,Integer> lastSeen = new HashMap<Integer, Integer>();        // and the step they were seen    

    int        simStep  = 0;
    
    WriteStatusThread writeStatusThread = null;
    
    protected Logger logger = Logger.getLogger(CowboyArch.class.getName());

    public static Atom aOBSTACLE    = new Atom("obstacle");
    public static Atom aENEMY       = new Atom("enemy");
    public static Atom aENEMYCORRAL = new Atom("enemycorral");
    public static Atom aALLY        = new Atom("ally");
    public static Atom aEMPTY       = new Atom("empty");
    public static Atom aSWITCH      = new Atom("switch");
    public static Atom aFENCE       = new Atom("fence");
    public static Atom aOPEN        = new Atom("open");
    public static Atom aCLOSED      = new Atom("closed");
    
    
    @Override
    public void initAg(String agClass, ClassParameters bbPars, String asSrc, Settings stts) throws JasonException {
        super.initAg(agClass, bbPars, asSrc, stts);
        //model = new LocalWorldModel(150,150, WorldModel.agsByTeam, getTS().getAg().getBB()); // just to have a default model
        gui = "yes".equals(stts.getUserParameter("gui"));
        if (getMyId() == 0)
            gui = true;
        boolean writeStatus = "yes".equals(stts.getUserParameter("write_status"));
        boolean dumpAgsMind = "yes".equals(stts.getUserParameter("dump_ags_mind"));
        if (writeStatus || dumpAgsMind)
            writeStatusThread = WriteStatusThread.create(this, writeStatus, dumpAgsMind);
        
        teamId = stts.getUserParameter("teamid");
        if (teamId == null) 
            logger.info("*** No 'teamid' parameter!!!!");
        else if (teamId.startsWith("")) 
            teamId = teamId.substring(1, teamId.length()-1);
            
        
        WriteStatusThread.registerAgent(getAgName(), this);
        
        // create the viewer for contest simulator
        massimBackDir = stts.getUserParameter("ac_sim_back_dir");
        if (massimBackDir != null && massimBackDir.startsWith("\"")) 
            massimBackDir = massimBackDir.substring(1,massimBackDir.length()-1);
        logger = Logger.getLogger(CowboyArch.class.getName() + ".CA-" + getAgName());
        
        setCheckCommunicationLink(false);
        
        initialBeliefs();
	}
	
	void initialBeliefs() throws RevisionFailedException {
	    getTS().getAg().addBel( createLiteral("team_size", createNumber(WorldModel.agsByTeam)));
	    for (int i=1; i<=WorldModel.agsByTeam; i++)
	        getTS().getAg().addBel( createLiteral("agent_id", createAtom(teamId+i), createNumber(i)));
        getTS().getAg().addBel( createLiteral("cows_by_boy", createNumber(cluster.COWS_BY_BOY)));
	}
	
	@Override
	public void stopAg() {
		if (view != null)   view.dispose();
		//if (acView != null) acView.finish();
		if (writeStatusThread != null) writeStatusThread.interrupt();
		super.stopAg();
	}

	//@Override
	//public boolean isCrashed() {
	//    return playing && super.isCrashed();
	//}
	
    void setSimId(String id) {
        simId = id;
    }
    public String getSimId() {
        return simId;
    }

    public boolean hasGUI() {
    	return gui;
    }
    
	public int getMyId() {
		if (myId < 0) 
			myId = getAgId(getAgName());
		return myId;
	}

	public LocalWorldModel getModel() {
		return model;
	}
	
	/*
	public ACViewer getACViewer() {
	    return acView;
	} */

    /** The perception of the grid size is removed from the percepts list 
        and "directly" added as a belief */
    void gsizePerceived(int w, int h, String opponent) throws RevisionFailedException {
        //logger.info("--- received gsize");
        model = new LocalWorldModel(w, h, WorldModel.agsByTeam, getTS().getAg().getBB());
        model.setOpponent(opponent);
        getTS().getAg().addBel(Literal.parseLiteral("gsize("+w+","+h+")"));
        playing = true;

        // manage GUIs
        if (view != null)   view.dispose();
        //if (acView != null) acView.finish();
        if (gui) {
            try { // isolate problem with GUI
                view = new WorldView("Herding (view of cowboy "+(getMyId()+1)+") -- against "+opponent,model);
            } catch (Exception e) {
                logger.info("error starting GUI");
                e.printStackTrace();
            }
        }
        if (writeStatusThread != null)  writeStatusThread.reset();

        //if (massimBackDir != null && massimBackDir.length() > 0) { 
        //    acView = new ACViewer(massimBackDir, w, h);
        //    acView.setPriority(Thread.MIN_PRIORITY);
        //    acView.start();
        //}
    }
    
    /** The perception of the corral location is removed from the percepts list 
        and "directly" added as a belief */
    void corralPerceived(Location upperLeft, Location downRight) throws RevisionFailedException  {
        model.setCorral(upperLeft, downRight);
        //if (acView != null) acView.getModel().setCorral(upperLeft, downRight);
        getTS().getAg().addBel(createLiteral("corral", createNumber(upperLeft.x),createNumber(upperLeft.y),createNumber(downRight.x),createNumber(downRight.y)));
    }

    /** The number of steps of the simulation is removed from the percepts list 
        and "directly" added as a belief */
    void stepsPerceived(int s) throws RevisionFailedException {
    	getTS().getAg().addBel(createLiteral("steps", createNumber(s)));
        model.setMaxSteps(s);
        
        // try to load obstacles from file
        model.restoreObstaclesFromFile(this);
        model.createStoreObsThread(this);
    }

    /** update set set of perceived cows */
    public void cowPerceived(int cowId, int x, int y) {
        Location c = new Location(x, y);
        if (model.getCorral().contains(c)) {// cows in the corral are not perceived
            perceivedCows.remove(cowId);
            lastSeen.remove(cowId);
        } else {
            perceivedCows.put(cowId, c);
            lastSeen.put(cowId, getSimStep());
        }
    }
    
    public void removeFarCowsFromPerception() {
        Iterator<Location> i = perceivedCows.values().iterator();
        while (i.hasNext()) {
            Location l = i.next();
            if (getModel().getAgPos(getMyId()).distanceChebyshev(l)/2 > getModel().getAgPerceptionRatio()) {
                //logger.info(getModel().getAgPerceptionRatio()+" iiiiii removing cow "+l+" i am at "+getModel().getAgPos(getMyId())+ " dist "+getModel().getAgPos(getMyId()).maxBorder(l));
                i.remove();
            }
        }
        Iterator<Integer> ic = perceivedCows.keySet().iterator();
        while (ic.hasNext()) {
            int cow = ic.next();
            if (getSimStep() - lastSeen.get(cow) > 5) { // not seen in 5 steps, remove
                ic.remove();
                //logger.info(" iiiiii removing cow "+cow+" from perception since it was not seen for a long time, seen at "+lastSeen.get(cow)+" now is "+getSimStep());
            }
        }
    }
    public Map<Integer,Location> getPerceivedCows() {
        return perceivedCows;
    }
    public int getLastSeenCow(int cow) {
        return lastSeen.get(cow);
    }
    
	/** update the model with obstacle and share them with the team mates */
	public void obstaclePerceived(int x, int y) {
	    //getTS().getLogger().info("perceived obstacle bbbb "+x+","+y+"   "+model.hasObject(WorldModel.OBSTACLE, x, y));
		if (! model.hasObject(WorldModel.OBSTACLE, x, y)) {
			model.add(WorldModel.OBSTACLE, x, y);
			//if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);
			Message m = new Message("tell", null, null, createCellPerception(x, y, aOBSTACLE));
            try { broadcast(m); } catch (Exception e) { e.printStackTrace(); }
		} else {
		    Location l = new Location(x, y);
		    if (ephemeralObstacle.remove(l))
	           logger.info("uuuuu ephemeral location "+l+" perceived! so, it is no more ephemeral.");
		}
	}

	public void enemyCorralPerceived(int x, int y) {
		if (! model.hasObject(WorldModel.ENEMYCORRAL, x, y)) {
			model.add(WorldModel.ENEMYCORRAL, x, y);
			//if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);
			Message m = new Message("tell", null, null, createCellPerception(x, y, aENEMYCORRAL));
			try { broadcast(m); } catch (Exception e) {	e.printStackTrace(); }
		}		
	}

    public void fencePerceived(int x, int y, boolean open) {
        int obj;
        Atom s;
        if (open) {
            obj = WorldModel.OPEN_FENCE;
            s   = aOPEN;
        } else {
            obj = WorldModel.CLOSED_FENCE;
            s   = aCLOSED;
        }       
        if (!model.hasObject(obj, x, y)) {
            model.add(obj, x, y);
            //if (acView != null) acView.addObject(obj, x, y);
            Message m = new Message("tell", null, null, createCellPerception(x, y, ASSyntax.createStructure(aFENCE.toString(), s)));
            try { broadcast(m); } catch (Exception e) { e.printStackTrace(); }
        }
    }
    
    public void switchPerceived(int x, int y) throws RevisionFailedException {
        if (!model.hasObject(WorldModel.SWITCH, x, y)) {
            getTS().getAg().addBel(createLiteral("switch", createNumber(x), createNumber(y)));

            //if (acView != null) acView.addObject(WorldModel.SWITCH, x, y);
            Message m = new Message("tell", null, null, createCellPerception(x, y, aSWITCH));
            try { broadcast(m); } catch (Exception e) { e.printStackTrace(); }
        }
        model.add(WorldModel.SWITCH, x, y); // always add in the model due to the problem of setting the near obstacle
    }
    
	public void lineOfSightPerceived(int line) throws RevisionFailedException {
		model.setAgPerceptionRatio(line);
		getTS().getAg().addBel(createLiteral("ag_perception_ratio", createNumber(line)));
        getTS().getAg().addBel(createLiteral("cow_perception_ratio", createNumber(WorldModel.cowPerceptionRatio)));
	}

	/*
    Location lo1 = new Location(-1,-1), // last locations of the agent 
             lo2 = new Location(-1,-1), 
             lo3 = new Location(-1,-1), 
             lo4 = new Location(-1,-1),
             lo5 = new Location(-1,-1),
             lo6 = new Location(-1,-1),
             lo7 = new Location(-1,-1);
    */
	
	private static final int lastRecordCapacity = 7; 
    Queue<Location> lastLocations = new LinkedBlockingQueue<Location>(lastRecordCapacity); // last locations of the agent
    Queue<Move>     lastActions   = new LinkedBlockingQueue<Move>(lastRecordCapacity); // last actions
    Set<Location>   ephemeralObstacle = new HashSet<Location>();
    ScheduledExecutorService schedule = new ScheduledThreadPoolExecutor(30);
    
    private static <T> void myAddQueue(Queue<T> q, T e) {
        if (!q.offer(e)) {
            q.poll();
            q.offer(e);
        }
    }
    
    private static <T> boolean allEquals(Queue<T> q) {
        //return lo1.equals(lo2) && lo2.equals(lo3) && lo3.equals(lo4) && lo4.equals(lo5) && lo5.equals(lo6) && lo6.equals(lo7);
        if (q.size()+1 < lastRecordCapacity)
            return false;
        Iterator<T> il = q.iterator();
        if (il.hasNext()) {
            T first = il.next();
            while (il.hasNext()) {
                T other = il.next();
                if (! first.equals(other)) {
                    return false;
                }
            }
        }
        return true;
    }

    public boolean isEphemeralObstacle(Location l) {
        return ephemeralObstacle.contains(l);
    }
    
    Location oldLoc;
    /** the location in previous cycle */
	public Location getLastLocation() {
	    return oldLoc; 
	}
	
	public Queue<Location> getLastLocations() {
	    return lastLocations;
	}
	
	protected String lastAct;
	protected void setLastAct(String act) {
	    lastAct = act;
	    if (act != null)
	        myAddQueue(lastActions, Move.valueOf(act));
	}
	public String getLastAction() {
	    return lastAct;
	}
	
	public int getSimStep() {
	    return simStep;
	}
	
	
	/** update the model with the agent location and share this information with team mates */
	void locationPerceived(final int x, final int y) {
	    if (model == null) {
	        logger.info("***** No model created yet! I cannot set my location");
	        return;
	    }
		oldLoc = model.getAgPos(getMyId());
        if (oldLoc != null) {
            model.clearAgView(oldLoc); // clear golds and  enemies
        }
		if (oldLoc == null || !oldLoc.equals(new Location(x,y))) {
			try {
				model.setAgPos(getMyId(), x, y);
				//if (acView != null) acView.getModel().setAgPos(getMyId(), x, y);
				model.incVisited(x, y);
			
				Message m = new Message("tell", null, null, "my_status("+x+","+y+")");
				broadcast(m);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		myAddQueue(lastLocations, new Location(x, y));
		checkRestart();
	}
	
	/** returns true if the agent do not move in the last 5 location perception */
	/*
	public boolean isNotMoving() {
	    return allEquals(lastLocations);
		//return lo1.equals(lo2) && lo2.equals(lo3) && lo3.equals(lo4) && lo4.equals(lo5) && lo5.equals(lo6) && lo6.equals(lo7);
	    if (lastLocations.size()+2 < lastRecordCapacity)
	        return false;
	    Iterator<Location> il = lastLocations.iterator();
	    if (il.hasNext()) {
	        Location first = il.next();
	        while (il.hasNext()) {
	            Location other = il.next();
	            if (! first.equals(other)) {
	                return false;
	            }
	        }
	    }
	    return true;
	}
	*/
	
	protected void checkRestart() {
        if (allEquals(lastLocations)) {
            
            try {
                logger.info("** Arch adding restart for "+getAgName()+", last locations are "+lastLocations);
                //getTS().getC().create(); // it is terrible for pending intentions of cowboys!
                getTS().getC().addAchvGoal(new LiteralImpl("restart"), Intention.EmptyInt);
                //lo2 = new Location(-1,-1); // to not restart again in the next cycle
                lastLocations.clear();
                
                perceivedCows.clear(); // TODO: we should not do that, but it seems this perceived cows is bugged. 
                lastSeen.clear();
            } catch (Exception e) {
                logger.info("Error in restart!"+ e);
            }

            if (allEquals(lastActions) && lastActions.iterator().next() != Move.skip) {
                final Location newLoc = WorldModel.getNewLocationForAction(getLastLocation(), lastActions.peek());
                if (newLoc != null && !model.hasObject(WorldModel.OBSTACLE, newLoc)) {
                    if (model.hasObject(WorldModel.FENCE, newLoc)) {
                        logger.info("uuu adding restart for "+getAgName()+", case of fence, last actions "+lastActions);
                        getTS().getC().addAchvGoal(new LiteralImpl("restart_fence_case"), Intention.EmptyInt);
                    } else {
                        logger.info("uuu last actions and locations do not change!!!! setting "+newLoc+" as ephemeral obstacle");
                        model.add(WorldModel.OBSTACLE, newLoc);
                        //if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);
                        ephemeralObstacle.add(newLoc);
                        
                        // remove this obstacle after 10 seconds
                        schedule.schedule(new Runnable() {
                            public void run() {
                                if (ephemeralObstacle.contains(newLoc)) { // the location is still ephemeral (not perceived)
                                    logger.info("uuuuuuu removing ephemeral location "+newLoc);
                                    model.remove(WorldModel.OBSTACLE, newLoc);
                                }
                            }
                        }, 10, TimeUnit.SECONDS);
                    }
                }
            }
        }	    
	}
	
    public static Literal createCellPerception(int x, int y, Term obj) {
        return createLiteral("cell", createNumber(x), createNumber(y), obj); 
    }

    void initKnownCows() {
    	model.clearKnownCows();
    }
    
    void enemyPerceived(int x, int y) {
        model.add(WorldModel.ENEMY, x, y); 
    }

    void simulationEndPerceived(String result) throws RevisionFailedException {
    	getTS().getAg().addBel(Literal.parseLiteral("end_of_simulation("+result+")"));
    	model   = null;
        playing = false;
        perceivedCows.clear();
        lastSeen.clear();
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
    	//String basename = getAgName().substring(0,getAgName().length()-1);
        if (model == null) return;
    	for (int i=1; i <= model.getAgsByTeam() ; i++) {
    	    String oname = teamId+i;
    		if (!getAgName().equals(oname)) {
    			Message msg = new Message(m);
    			msg.setReceiver(oname);
    			for (int t=0; t<6; t++) {
	    			try {
	    			    sendMsg(msg);
	    			    break; // the for
	    			} catch (ReceiverNotFoundException e) {
	    			    logger.info("Receiver "+oname+" not found: wait and try later, "+t);
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
	    			if (ms.startsWith("cell") && model != null) {
                        im.remove();

                        Literal p = (Literal)m.getPropCont();
	    				int x = (int)((NumberTerm)p.getTerm(0)).solve();
	    				int y = (int)((NumberTerm)p.getTerm(1)).solve();
	    				if (model.inGrid(x,y)) {
	    				    if (p.getTerm(2) == aOBSTACLE) {
    	    					model.add(WorldModel.OBSTACLE, x, y);
    	    					//if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);
	    				    } else if (p.getTerm(2) == aENEMYCORRAL) {
                                model.add(WorldModel.ENEMYCORRAL, x, y);
                                //if (acView != null) acView.addObject(WorldModel.OBSTACLE, x, y);	    				        
                            } else if (p.getTerm(2) == aSWITCH) {
                                model.add(WorldModel.SWITCH, x, y);
                                //if (acView != null) acView.addObject(WorldModel.SWITCH, x, y);
                                Literal l = createLiteral("switch", createNumber(x), createNumber(y));
                                l.addSource(createAtom(m.getSender()));
                                getTS().getAg().addBel(l);                                
                            } else if (p.getTerm(2).toString().startsWith(aFENCE.toString())) {
                                Structure s = (Structure)p.getTerm(2);
                                if (s.getTerm(0) == aOPEN) {
                                    model.add(WorldModel.OPEN_FENCE, x, y);
                                    //if (acView != null) acView.addObject(WorldModel.OPEN_FENCE, x, y);
                                } else if (s.getTerm(0) == aCLOSED) {
                                    model.add(WorldModel.CLOSED_FENCE, x, y);
                                    //if (acView != null) acView.addObject(WorldModel.CLOSED_FENCE, x, y);
                                }
	    				    }
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
	    						//if (acView != null) acView.getModel().setAgPos(agid, x, y);
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

	/** returns the number of the agent based on its name (the number in the end of the name, e.g. dummie9 ==> id = 8) */
    public static int getAgId(String agName) {
        boolean nbWith2Digits = Character.isDigit(agName.charAt(agName.length()-2));
        if (nbWith2Digits)
            return (Integer.parseInt(agName.substring(agName.length()-2))) -1;     
        else
            return (Integer.parseInt(agName.substring(agName.length()-1))) -1;    	
    }

}

