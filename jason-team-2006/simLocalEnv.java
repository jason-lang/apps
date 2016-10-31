// Environment code for project jasonTeamSimLocal.mas2j

import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import jasonteam.Location;
import jasonteam.WorldModel;
import jasonteam.WorldView;

import java.util.logging.Level;
import java.util.logging.Logger;

public class simLocalEnv extends jason.environment.Environment {

	private Logger logger = Logger.getLogger("jasonTeamSimLocal.mas2j."+simLocalEnv.class.getName());

    WorldModel model;
    WorldView view;
    
    int simId = 5;
    int nbWorlds = 5;
    
    public static final int SIM_TIME = 60; // in seconds
    
    Term up    = Term.parse("do(up)");
    Term down  = Term.parse("do(down)");
    Term right = Term.parse("do(right)");
    Term left  = Term.parse("do(left)");
    Term skip  = Term.parse("do(skip)");
    Term pick  = Term.parse("do(pick)");
    Term drop  = Term.parse("do(drop)");
	
    static private final int UP = 0;
    static private final int DOWN = 1;
    static private final int RIGHT = 2;
    static private final int LEFT = 3;
    
    
    public simLocalEnv() {
    	initWorld(simId);
        new Thread() {
        	public void run() {
        		while (true) {
	        		try {
	        			sleep(SIM_TIME * 1000);
	        			endSimulation();
	        		} catch (Exception e) {
	        			logger.log(Level.SEVERE, "Error!",e);
	        		}
        		}
        	}
        }.start();
	}
    
    private void initWorld(int w) {
    	switch (w) {
		case 1: world1(); break;
		case 2: world2(); break;
		case 3: world3(); break;
		case 4: world4(); break;
		case 5: world5(); break;
		default: logger.info("Invalid index!"); return;
		}
        view = WorldView.create(model);
        
        addPercept(Literal.parseLiteral("gsize("+simId+","+model.getWidth()+","+model.getHeight()+")"));
        addPercept(Literal.parseLiteral("depot("+simId+","+model.getDepot().x+","+model.getDepot().y+")"));
        
        updateAgsPercept();    	
    }
    
    private void endSimulation() {
        for (int i=0; i<model.getNbOfAgs(); i++) {
            clearPercepts("miner"+(i+1));
        }
    	clearPercepts();
		addPercept(Literal.parseLiteral("endOfSimulation("+simId+",0)"));
		simId++;
		WorldView.destroy();
		WorldModel.destroy();
		initWorld( (simId % nbWorlds) +1);//new Random().nextInt(3)+1);
    }
        
    /** no gold/no obstacle world */
    private void world1() {
        model = WorldModel.create(21,21,4);
        model.setDepot(5,7);
        model.setAgPos(0, 1, 0);
        model.setAgPos(1, 20, 0);
        model.setAgPos(2, 3, 20);
        model.setAgPos(3, 20, 20);
    }

    private void world2() {
        model = WorldModel.create(10,10,4);
        model.setDepot(5,7);
        model.setAgPos(0, 1, 0);
        model.setAgPos(1, 1, 2);
        model.setAgPos(2, 1, 3);
        model.setAgPos(3, 1, 4);
    }

    /** world with gold, no obstacle */
    private void world3() {
        model = WorldModel.create(15,15,4);
        model.setDepot(5,7);
        model.setAgPos(0, 1, 0);
        model.setAgPos(1, 10, 0);
        model.setAgPos(2, 3, 10);
        model.setAgPos(3, 10, 10);
        model.add(WorldModel.GOLD, 10,10);
        model.add(WorldModel.GOLD, 10,14);
    }

    /** world with gold, no obstacle */
    private void world4() {
        model = WorldModel.create(35,35,4);
        model.setDepot(5,27);
        model.setAgPos(0, 1, 0);
        model.setAgPos(1, 20, 0);
        model.setAgPos(2, 3, 20);
        model.setAgPos(3, 20, 20);
        model.add(WorldModel.GOLD, 20,13);
        model.add(WorldModel.GOLD, 15,20);
        model.add(WorldModel.GOLD, 1,1);
        model.add(WorldModel.GOLD, 3,5);
        model.add(WorldModel.GOLD, 24,24);
        model.add(WorldModel.GOLD, 20,20);
        model.add(WorldModel.GOLD, 20,21);
        model.add(WorldModel.GOLD, 20,22);
        model.add(WorldModel.GOLD, 20,23);
        model.add(WorldModel.GOLD, 20,24);
        model.add(WorldModel.GOLD, 19,20);
        model.add(WorldModel.GOLD, 19,21);
        model.add(WorldModel.GOLD, 34,34);
    }

    /** world with gold and obstacles */
    private void world5() {
        model = WorldModel.create(35,35,4);
        model.setDepot(16,16);
        model.setAgPos(0, 1, 0);
        model.setAgPos(1, 20, 0);
        model.setAgPos(2, 6, 26);
        model.setAgPos(3, 20, 20);
        model.add(WorldModel.GOLD, 20,13);
        model.add(WorldModel.GOLD, 15,20);
        model.add(WorldModel.GOLD, 1,1);
        model.add(WorldModel.GOLD, 3,5);
        model.add(WorldModel.GOLD, 24,24);
        model.add(WorldModel.GOLD, 20,20);
        model.add(WorldModel.GOLD, 20,21);
        model.add(WorldModel.GOLD, 2,22);
        model.add(WorldModel.GOLD, 2,23);
        model.add(WorldModel.GOLD, 2,12);
        model.add(WorldModel.GOLD, 19,2);
        model.add(WorldModel.GOLD, 14,4);
        model.add(WorldModel.GOLD, 34,34);

        model.add(WorldModel.OBSTACLE, 12,3);
        model.add(WorldModel.OBSTACLE, 13,3);
        model.add(WorldModel.OBSTACLE, 14,3);
        model.add(WorldModel.OBSTACLE, 15,3);
        model.add(WorldModel.OBSTACLE, 18,3);
        model.add(WorldModel.OBSTACLE, 19,3);
        model.add(WorldModel.OBSTACLE, 20,3);
        model.add(WorldModel.OBSTACLE, 14,8);
        model.add(WorldModel.OBSTACLE, 15,8);
        model.add(WorldModel.OBSTACLE, 16,8);
        model.add(WorldModel.OBSTACLE, 17,8);
        model.add(WorldModel.OBSTACLE, 19,8);
        model.add(WorldModel.OBSTACLE, 20,8);

        model.add(WorldModel.OBSTACLE, 12,32);
        model.add(WorldModel.OBSTACLE, 13,32);
        model.add(WorldModel.OBSTACLE, 14,32);
        model.add(WorldModel.OBSTACLE, 15,32);
        model.add(WorldModel.OBSTACLE, 18,32);
        model.add(WorldModel.OBSTACLE, 19,32);
        model.add(WorldModel.OBSTACLE, 20,32);
        model.add(WorldModel.OBSTACLE, 14,28);
        model.add(WorldModel.OBSTACLE, 15,28);
        model.add(WorldModel.OBSTACLE, 16,28);
        model.add(WorldModel.OBSTACLE, 17,28);
        model.add(WorldModel.OBSTACLE, 19,28);
        model.add(WorldModel.OBSTACLE, 20,28);

        model.add(WorldModel.OBSTACLE, 3,12);
        model.add(WorldModel.OBSTACLE, 3,13);
        model.add(WorldModel.OBSTACLE, 3,14);
        model.add(WorldModel.OBSTACLE, 3,15);
        model.add(WorldModel.OBSTACLE, 3,18);
        model.add(WorldModel.OBSTACLE, 3,19);
        model.add(WorldModel.OBSTACLE, 3,20);
        model.add(WorldModel.OBSTACLE, 8,14);
        model.add(WorldModel.OBSTACLE, 8,15);
        model.add(WorldModel.OBSTACLE, 8,16);
        model.add(WorldModel.OBSTACLE, 8,17);
        model.add(WorldModel.OBSTACLE, 8,19);
        model.add(WorldModel.OBSTACLE, 8,20);

        model.add(WorldModel.OBSTACLE, 32,12);
        model.add(WorldModel.OBSTACLE, 32,13);
        model.add(WorldModel.OBSTACLE, 32,14);
        model.add(WorldModel.OBSTACLE, 32,15);
        model.add(WorldModel.OBSTACLE, 32,18);
        model.add(WorldModel.OBSTACLE, 32,19);
        model.add(WorldModel.OBSTACLE, 32,20);
        model.add(WorldModel.OBSTACLE, 28,14);
        model.add(WorldModel.OBSTACLE, 28,15);
        model.add(WorldModel.OBSTACLE, 28,16);
        model.add(WorldModel.OBSTACLE, 28,17);
        model.add(WorldModel.OBSTACLE, 28,19);
        model.add(WorldModel.OBSTACLE, 28,20);

        model.add(WorldModel.OBSTACLE, 13,13);
        model.add(WorldModel.OBSTACLE, 13,14);

        model.add(WorldModel.OBSTACLE, 13,16);
        model.add(WorldModel.OBSTACLE, 13,17);

        model.add(WorldModel.OBSTACLE, 13,19);
        model.add(WorldModel.OBSTACLE, 14,19);

        model.add(WorldModel.OBSTACLE, 16,19);
        model.add(WorldModel.OBSTACLE, 17,19);

        model.add(WorldModel.OBSTACLE, 19,19);
        model.add(WorldModel.OBSTACLE, 19,18);

        model.add(WorldModel.OBSTACLE, 19,16);
        model.add(WorldModel.OBSTACLE, 19,15);

        model.add(WorldModel.OBSTACLE, 19,13);
        model.add(WorldModel.OBSTACLE, 18,13);

        model.add(WorldModel.OBSTACLE, 16,13);
        model.add(WorldModel.OBSTACLE, 15,13);


	// labirinto
        model.add(WorldModel.OBSTACLE, 2,32);
        model.add(WorldModel.OBSTACLE, 3,32);
        model.add(WorldModel.OBSTACLE, 4,32);
        model.add(WorldModel.OBSTACLE, 5,32);
        model.add(WorldModel.OBSTACLE, 6,32);
        model.add(WorldModel.OBSTACLE, 7,32);
        model.add(WorldModel.OBSTACLE, 8,32);
        model.add(WorldModel.OBSTACLE, 9,32);
        model.add(WorldModel.OBSTACLE, 10,32);
        model.add(WorldModel.OBSTACLE, 10,31);
        model.add(WorldModel.OBSTACLE, 10,30);
        model.add(WorldModel.OBSTACLE, 10,29);
        model.add(WorldModel.OBSTACLE, 10,28);
        model.add(WorldModel.OBSTACLE, 10,27);
        model.add(WorldModel.OBSTACLE, 10,26);
        model.add(WorldModel.OBSTACLE, 10,25);
        model.add(WorldModel.OBSTACLE, 10,24);
        model.add(WorldModel.OBSTACLE, 10,23);
        model.add(WorldModel.OBSTACLE, 2,23);
        model.add(WorldModel.OBSTACLE, 3,23);
        model.add(WorldModel.OBSTACLE, 4,23);
        model.add(WorldModel.OBSTACLE, 5,23);
        model.add(WorldModel.OBSTACLE, 6,23);
        model.add(WorldModel.OBSTACLE, 7,23);
        model.add(WorldModel.OBSTACLE, 8,23);
        model.add(WorldModel.OBSTACLE, 9,23);
        model.add(WorldModel.OBSTACLE, 2,29);
        model.add(WorldModel.OBSTACLE, 2,28);
        model.add(WorldModel.OBSTACLE, 2,27);
        model.add(WorldModel.OBSTACLE, 2,26);
        model.add(WorldModel.OBSTACLE, 2,25);
        model.add(WorldModel.OBSTACLE, 2,24);
        model.add(WorldModel.OBSTACLE, 2,23);
        model.add(WorldModel.OBSTACLE, 2,29);
        model.add(WorldModel.OBSTACLE, 3,29);
        model.add(WorldModel.OBSTACLE, 4,29);
        model.add(WorldModel.OBSTACLE, 5,29);
        model.add(WorldModel.OBSTACLE, 6,29);
        model.add(WorldModel.OBSTACLE, 7,29);
        model.add(WorldModel.OBSTACLE, 7,28);
        model.add(WorldModel.OBSTACLE, 7,27);
        model.add(WorldModel.OBSTACLE, 7,26);
        model.add(WorldModel.OBSTACLE, 7,25);
        model.add(WorldModel.OBSTACLE, 6,25);
        model.add(WorldModel.OBSTACLE, 5,25);
        model.add(WorldModel.OBSTACLE, 4,25);
        model.add(WorldModel.OBSTACLE, 4,26);
        model.add(WorldModel.OBSTACLE, 4,27);
    }

    private void updateAgsPercept() {
        for (int i=0; i<model.getNbOfAgs(); i++) {
            updateAgPercept(i);
        }
    }
    private void updateAgPercept(int ag) {
        updateAgPercept("miner"+(ag+1), ag);
    }
    private void updateAgPercept(String agName, int ag) {
        clearPercepts(agName);
        // its location
        Location l = model.getAgPos(ag);
        addPercept(agName, Literal.parseLiteral("pos("+l.x+","+l.y+")"));

        // what's arount
        updateAgPercept(agName,l.x-1,l.y-1);
        updateAgPercept(agName,l.x-1,l.y);
        updateAgPercept(agName,l.x-1,l.y+1);
        updateAgPercept(agName,l.x,l.y-1);
        updateAgPercept(agName,l.x,l.y);
        updateAgPercept(agName,l.x,l.y+1);
        updateAgPercept(agName,l.x+1,l.y-1);
        updateAgPercept(agName,l.x+1,l.y);
        updateAgPercept(agName,l.x+1,l.y+1);
    }
    private void updateAgPercept(String agName, int x, int y) {
        if (x < 0 || x >= model.getWidth() || y < 0 || y >= model.getHeight()) return;
        if (model.hasObject(WorldModel.OBSTACLE,x,y)) {
            addPercept(agName, Literal.parseLiteral("cell("+x+","+y+",obstacle)"));
        } else {
            if (model.hasObject(WorldModel.EMPTY,x,y)) {
                addPercept(agName, Literal.parseLiteral("cell("+x+","+y+",empty)"));
            }
            if (model.hasObject(WorldModel.GOLD,x,y)) {
                addPercept(agName, Literal.parseLiteral("cell("+x+","+y+",gold)"));
            }
            if (model.hasObject(WorldModel.ENEMY,x,y)) {
                addPercept(agName, Literal.parseLiteral("cell("+x+","+y+",enemy)"));
            }
            if (model.hasObject(WorldModel.ALLY,x,y)) {
                addPercept(agName, Literal.parseLiteral("cell("+x+","+y+",ally)"));
            }
        }
    }
    
    
    /** Actions **/
    
    
    private boolean move(int dir, int ag) {
        Location l = model.getAgPos(ag);
        model.remove(WorldModel.ALLY, l.x, l.y);
        switch (dir) {
        case UP: 
            if (model.isFree(l.x, l.y-1)) {
                model.setAgPos(ag, l.x, l.y-1);
            }
            break;
        case DOWN:
            if (model.isFree(l.x, l.y+1)) {
                model.setAgPos(ag, l.x, l.y+1);
            }
            break;
        case RIGHT:
            if (model.isFree(l.x+1, l.y)) {
                model.setAgPos(ag, l.x+1, l.y);
            }
            break;
        case LEFT:
            if (model.isFree(l.x-1, l.y)) {
                model.setAgPos(ag, l.x-1, l.y);
            }
            break;
        }
        l = model.getAgPos(ag);
        model.add(WorldModel.ALLY, l.x, l.y);
        updateAgPercept(ag);
        view.update();
        return true;
    }

    private boolean pick(int ag) {
        Location l = model.getAgPos(ag);
        if (model.hasObject(WorldModel.GOLD,l.x,l.y)) {
        	if (!model.isCarryingGold(ag)) {
	            model.remove(WorldModel.GOLD,l.x,l.y);
	            model.setAgCarryingGold(ag);
	            updateAgPercept(ag);
        	} else {
            	logger.warning("Agent "+(ag+1)+" is trying the pick gold, but it is already carrying gold!");        		
        	}
        } else {
        	logger.warning("Agent "+(ag+1)+" is trying the pick gold, but there is no gold at "+l.x+"x"+l.y+"!");
        }
        return true; // as in Clima contest, do action does not fail.
    }
    
    private boolean drop(int ag) {
        Location l = model.getAgPos(ag);
        if (model.isCarryingGold(ag)) {
            if (l.equals(model.getDepot())) {
                logger.info("Agent "+(ag+1)+" carried a gold to depot!");
            } else {
                model.add(WorldModel.GOLD,l.x,l.y);
            }
            model.setAgNotCarryingGold(ag);
            updateAgPercept(ag);
            return true;
        }
        return false;
    }

    public boolean executeAction(String ag, Term action) {
        
        try {
            Thread.sleep(50);
            int agId = (Integer.parseInt(ag.substring(5))) -1;
        
            if (action.equals(up))           { return move(UP, agId);
            } else if (action.equals(down))  { return move(DOWN, agId);
            } else if (action.equals(right)) { return move(RIGHT, agId);
            } else if (action.equals(left))  { return move(LEFT, agId);
            } else if (action.equals(skip))  { return true;
            } else if (action.equals(pick))  { return pick(agId);
            } else if (action.equals(drop))  { return drop(agId);
            } else {
                logger.info("executing: "+action+", but not implemented!");
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "error executing "+action+" for "+ag, e);
        }
		return false;
	}
}

