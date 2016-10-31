package arch;

import static jason.asSyntax.ASSyntax.createLiteral;
import static jason.asSyntax.ASSyntax.createNumber;
import static jason.asSyntax.ASSyntax.createStructure;
import jason.asSyntax.Literal;
import jason.environment.grid.Location;

import java.io.FileWriter;
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

import env.Cow;


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

	private long timeSt,timeEnd; 

	//private static CyclicBarrier perceptionBarrier = new CyclicBarrier(WorldModel.agsByTeam);

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

			int lineOfSight = Integer.parseInt(simulation.getAttribute("lineOfSight"));
			arq.lineOfSightPerceived(lineOfSight);

			logger.info("Start simulation processed ok!");

			rid = simulation.getAttribute("id");
			//sendAction(null); // TODO: check if still needed. the start requires an answer!
			timeSt=currenttime;

		} catch (Exception e) {
			logger.log(Level.SEVERE, "error processing start",e);
		}
	}

	public void processSimulationEnd(Element result, long currenttime) {
		try {
			timeEnd=currenttime;
			String score = result.getAttribute("score") +"-"+ result.getAttribute("result");
			logger.info("End of simulation :"+score);
			if(arq.myId==1)
			{
				logger.info("iiii End of simulation :"+score);
				logger.info("iiii The simulation last for " +(timeEnd-timeSt)+" milliseconds");
				logger.info("iiii The simulation last for " +(timeEnd-timeSt)/60000.0+" minutes");
				String fileName = "report2010.txt";
				FileWriter fw = new FileWriter(fileName,true);
				fw.write("=====================================\n");
				fw.write(timeEnd+"\n");
				fw.write((timeEnd-timeSt)+" milliseconds ("+(timeEnd-timeSt)/60000.0+" minutes)\n");
				fw.write(score+"\n");
				fw.close();
			}
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
			int score = Integer.parseInt(perception.getAttribute("cowsInCorral"));

			// update model
			arq.locationPerceived(agx, agy); // also calls clearAgView
			arq.setScore(score);

			arq.getCowModel().freePos(agx,agy);

			// add location in perception
			Literal lpos = createLiteral("pos", createNumber(agx), createNumber(agy), createNumber(step));
			percepts.add(lpos);

			arq.initKnownCows();

			List<Location> switches = new ArrayList<Location>(); // switch should be perceived later

			//int enemyId = 1;

			// add in perception what is around
			NodeList nl = perception.getElementsByTagName("cell");
			for (int i=0; i < nl.getLength(); i++) {
				Element cell = (Element)nl.item(i);
				int cellx = Integer.parseInt(cell.getAttribute("x"));
				int celly = Integer.parseInt(cell.getAttribute("y"));
				int absx  = agx + cellx;
				int absy  = agy + celly;
				int unk = 1; // the cell is unknown 

				NodeList cnl = cell.getChildNodes();
				for (int j=0; j < cnl.getLength(); j++) {
					if (cnl.item(j).getNodeType() == Element.ELEMENT_NODE && cellx != 0 && celly != 0) {

						Element type = (Element)cnl.item(j);

						if (unk==1 && ! type.getNodeName().equals("unknown")) { // if the position is known, should be cleared
							arq.getCowModel().freePos(absx,absy);
							unk=0; // the cell has became known
						}

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
								arq.cowPerceived(cowId, absx, absy);
							}

						} else if (type.getNodeName().equals("obstacle")) { 
							arq.obstaclePerceived(absx, absy);
						} else if (type.getNodeName().equals("corral") && type.getAttribute("type").equals("enemy")) { 
							arq.enemyCorralPerceived(absx, absy);
						} else if (type.getNodeName().equals("fence")) {
							//logger.info("iiii fence "+cellx+" "+celly+"  - "+absx+" "+absy+" - "+agx+" "+agy);
							boolean open = type.getAttribute("open").equals("true");
							arq.fencePerceived(absx, absy, open);
							/*
							   Atom state;
							   if (open) 
							   state = CowboyArch.aOPEN;
							   else
							   state = CowboyArch.aCLOSED;                            
							   Literal lf = createLiteral(CowboyArch.aFENCE.toString(), createNumber(absx), createNumber(absy), state);
							   percepts.add(lf);
							 */
						} else if (type.getNodeName().equals("switch")) {
							switches.add(new Location(absx, absy));
							//} else if (type.getNodeName().equals("empty")) {
							//    percepts.add(CowboyArch.createCellPerception(cellx, celly, CowboyArch.aEMPTY));
					}
					}
				}
			}

			/*
			   try {
			   perceptionBarrier.await(100, TimeUnit.MILLISECONDS); // all agents wait at most 100 Millis until the other also populate CowModel.
			   } catch (Exception e){}
			   perceptionBarrier.reset();
			 */

			arq.getCowModel().updateCows();

			// put switches
			for (Location l: switches) {
				arq.switchPerceived(l.x, l.y);
			}

			// puts cows in perception
			// arq.removeFarCowsFromPerception();

			Cow[] cows = arq.getCowModel().getCows();
			for (Cow cCow: cows) {

				Literal lc = createLiteral("cow", createNumber(cCow.id), createNumber(cCow.x), createNumber(cCow.y));
				lc.addAnnot(createStructure("step", createNumber( cCow.step )));
				percepts.add(lc);
			}

			//if (logger.isLoggable(Level.FINE)) 
			//logger.info("Request action for "+lpos+" / rid: "+rid+" / percepts: "+percepts);

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

	/** checks the connection */
	class ConnectionMonitor extends Thread {
		int     count = 0;

		synchronized  public void run() {
			int d = new Random().nextInt(1500);
			try {
				while (running) {
					if (isConnected())
						sleep(2000+d);
					else 
					{
						sleep(1500);
						logger.info("*** not connected!!! reconnecting");
						connect();
					}
					count++;
				}
			} catch (InterruptedException e) {
			} catch (Exception e) {
				logger.log(Level.WARNING,"Error in communication ",e);
			}
		}

	}
}