package arch;

import static jason.asSyntax.ASSyntax.createLiteral;
import static jason.asSyntax.ASSyntax.createNumber;

import jason.asSyntax.Literal;
import jason.asSyntax.LiteralImpl;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Structure;
import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;


/**  
 * Handle the (XML) communication with contest simulator. 
 * 
 * @author Jomi
 */
public class ACProxy extends ACAgent implements Runnable {

    String         rid; // the response id of the current cycle
    ACArchitecture arq;
    boolean        running = true;
    
    private Logger logger = Logger.getLogger(ACProxy.class.getName());
    private DocumentBuilder documentbuilder;

    ConnectionMonitor monitor = new ConnectionMonitor();
    
    public ACProxy(ACArchitecture arq, String host, int port, String username, String password) {
        logger = Logger.getLogger(ACProxy.class.getName()+"."+arq.getAgName());
        //logger.setLevel(Level.FINE);
        
        if (host.startsWith("\"")) {
			host = host.substring(1,host.length()-1);
		}
		setPort(port);
		setHost(host);
		setUsername(username);
		setPassword(password);
		this.arq = arq;
		try {
			documentbuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
			//transformer = TransformerFactory.newInstance().newTransformer();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
        connect();
		monitor.start();
	}
	
	public void finish() {
	    running = false;
	    monitor.interrupt();
	}
	
    public void run() {
        while (running) {
            try {
                if (isConnected()) {
                    Document doc = receiveDocument();
                    if (doc != null) {
                        Element el_root = doc.getDocumentElement();
        
                        if (el_root != null) {
                            if (el_root.getNodeName().equals("message")) {
                                processMessage(el_root);
                            } else {
                                logger.log(Level.SEVERE,"unknown document received");
                            }
                        } else {
                            logger.log(Level.SEVERE, "no document element found");
                        }
                    }
                } else {
                    // wait auto-reconnect
                    logger.info("waiting reconnection...");
                    try { Thread.sleep(2000); } catch (InterruptedException e1) {}
                }
            } catch (Exception e) {
                logger.log(Level.SEVERE, "ACProxy run exception", e);
            }
        }
    }

	
	public void processLogIn() {
		logger.info("---#-#-#-#-#-#-- login ok.");
	}

	public void processSimulationStart(Element simulation, long currenttime) {
		try {
			//opponent = simulation.getAttribute("opponent");
			//arq.addBel(Literal.parseLiteral("opponent("+simulationID+","+opponent+")"));
            arq.setSimId(simulation.getAttribute("id"));

			int gsizex = Integer.parseInt(simulation.getAttribute("gsizex"));
			int gsizey = Integer.parseInt(simulation.getAttribute("gsizey"));
            arq.gsizePerceived(gsizex,gsizey, simulation.getAttribute("opponent"));

			int corralx0 = Integer.parseInt(simulation.getAttribute("corralx0"));
            int corralx1 = Integer.parseInt(simulation.getAttribute("corralx1"));
            int corraly0 = Integer.parseInt(simulation.getAttribute("corraly0"));
            int corraly1 = Integer.parseInt(simulation.getAttribute("corraly1"));
            arq.corralPerceived(new Location(corralx0, corraly0), new Location(corralx1, corraly1));

			int steps  = Integer.parseInt(simulation.getAttribute("steps"));
            arq.stepsPerceived(steps);
			
			logger.info("Start simulation processed ok!");

			rid = simulation.getAttribute("id");
			sendAction(null); // TODO: check is still needed. the start requires an answer!
			
		} catch (Exception e) {
			logger.log(Level.SEVERE, "error processing start",e);
		}
	}

	public void processSimulationEnd(Element result, long currenttime) {
		try {
            String score = result.getAttribute("score") +"-"+ result.getAttribute("result");
			logger.info("End of simulation :"+score);
            arq.simulationEndPerceived(result.getAttribute("result"));
		} catch (Exception e) {
			logger.log(Level.SEVERE, "error processing end",e);
		}
	}

	public void processRequestAction(Element perception, long currenttime, long deadline) {
		try {
			List<Literal> percepts = new ArrayList<Literal>();
			
			rid = perception.getAttribute("id");
			int agx   = Integer.parseInt(perception.getAttribute("posx"));
			int agy   = Integer.parseInt(perception.getAttribute("posy"));
			int step  = Integer.parseInt(perception.getAttribute("step"));
            int score = Integer.parseInt(perception.getAttribute("score"));

            // update model
			arq.locationPerceived(agx, agy);
            arq.setScore(score);

            // add location in perception
			Literal lpos = createLiteral("pos", createNumber(agx), createNumber(agy), createNumber(step));
			percepts.add(lpos);

			arq.initKnownCows();
			
			//int enemyId = 1;
			
			// add in perception what is around
			NodeList nl = perception.getElementsByTagName("cell");
			for (int i=0; i < nl.getLength(); i++) {
				Element cell = (Element)nl.item(i);
				int cellx = Integer.parseInt(cell.getAttribute("x"));
                int celly = Integer.parseInt(cell.getAttribute("y"));
				int absx  = agx + cellx;
				int absy  = agy + celly;
				
				NodeList cnl = cell.getChildNodes();
				for (int j=0; j < cnl.getLength(); j++) {
					if (cnl.item(j).getNodeType() == Element.ELEMENT_NODE && cellx != 0 && celly != 0) {

						Element type = (Element)cnl.item(j);
						if (type.getNodeName().equals("agent")) {
							if (type.getAttribute("type").equals("ally")) {
							    // allies are managed by communication
								//percepts.add(CowboyArch.createCellPerception(cellx, celly, CowboyArch.aALLY));
							} else if (type.getAttribute("type").equals("enemy")) {
	                            //Structure le = new Literal("enemy");
	                            //le.addTerm(new NumberTermImpl( (enemyId++) )); // we need an id to work with UniqueBB
								//percepts.add(CowboyArch.createCellPerception(cellx, celly, le));
                                arq.enemyPerceived(absx, absy);
							}
                            
                        } else if (type.getNodeName().equals("cow")) {
                            // ignore cows in the border, they complicate all :-)
                            if (absx < arq.getModel().getWidth()-1 && absx != 0 && absy != 00 && absy < arq.getModel().getHeight()-1) {
                                int cowId = Integer.parseInt(type.getAttribute("ID"));
                                Literal lc = new LiteralImpl("cow");
                                lc.addTerms(new NumberTermImpl( cowId ), new NumberTermImpl( absx), new NumberTermImpl(absy));
                                Structure stepannot = new Structure("step",1); 
                                stepannot.addTerm(new NumberTermImpl(step));
                                lc.addAnnot(stepannot);
                                percepts.add(lc);
                                //arq.cowPerceived(absx, absy);
                            }
                            
                        } else if (type.getNodeName().equals("obstacle")) { 
							arq.obstaclePerceived(absx, absy, CowboyArch.createCellPerception(absx, absy, CowboyArch.aOBSTACLE));
                        } else if (type.getNodeName().equals("corral") && type.getAttribute("type").equals("enemy")) { 
                            arq.enemyCorralPerceived(absx, absy, CowboyArch.createCellPerception(absx, absy, CowboyArch.aENEMYCORRAL));
                            
                        //} else if (type.getNodeName().equals("empty")) {
                        //    percepts.add(CowboyArch.createCellPerception(cellx, celly, CowboyArch.aEMPTY));
						}
					}
				}
			}
	
            //if (logger.isLoggable(Level.FINE)) 
            logger.info("Request action for "+lpos+" / rid: "+rid+" / percepts: "+percepts);            
			
			//arq.sendCowsToTeam();
			arq.startNextStep(step, percepts);
			
		} catch (Exception e) {
			logger.log(Level.SEVERE, "error processing request",e);
		}
	}

	public void sendAction(String action) {
		try {
			logger.info("sending action "+action+" for rid "+rid+" at "+arq.model.getAgPos(arq.getMyId()) );
			Document doc = documentbuilder.newDocument();
			Element el_response = doc.createElement("message");
			
			el_response.setAttribute("type","action");
			doc.appendChild(el_response);

			Element el_action = doc.createElement("action");
			if (action != null) {
				el_action.setAttribute("type", action);
			}
			el_action.setAttribute("id",rid);
			el_response.appendChild(el_action);

			sendDocument(doc);
		} catch (Exception e) {
			logger.log(Level.SEVERE,"Error sending action.",e);
		}
	}

	@Override
	public void processPong(String pong) {
		monitor.processPong(pong);
	}

	/** checks the connection */
	class ConnectionMonitor extends Thread {
		long    sentTime = 0;
		int     count = 0;
		boolean ok = true;
		
		public void run() {
			int d = new Random().nextInt(10000);
            try {
                while (running) {
                    if (isConnected())
                        sleep(20000+d);
                    else 
                        sleep(2000);
					count++;
					ok = false;
					sentTime = System.currentTimeMillis();
					if (isConnected()) {
						sendPing("test:"+count);
						waitPong();
					}
					if (!ok) {
						logger.info("I likely loose my connection, reconnecting!");
						//reconnect();
						connect();
					}
			    }
            } catch (InterruptedException e) {
            } catch (Exception e) {
                logger.log(Level.WARNING,"Error in communication ",e);
            }
		}
		
		synchronized void waitPong() throws Exception {
			wait(4000);
		}
		
		synchronized void processPong(String pong) {
			long time = System.currentTimeMillis() - sentTime;
			logger.info("Pong "+pong+" in "+time+" milisec");
			ok = true;
			notify();
		}
	}
}
