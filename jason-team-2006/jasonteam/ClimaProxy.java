package jasonteam;

import jason.asSyntax.Literal;
import jason.asSyntax.NumberTermImpl;
import jason.asSyntax.Pred;
import jason.asSyntax.Term;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;


/**  
 * Handle the (XML) communication with Clima simulator, it is based on CliemaAgent class. 
 * This class also provides some GUI to see the agent's behaviour.
 * 
 * @author Jomi
 */
public class ClimaProxy extends ClimaAgent {

	private String simulationID;
	private String opponent;
	private int steps;
	
	private int agX=-1, agY=-1;
	private int agId = -1;
	
	String rid; // the response id of the current cycle
	
	ClimaArchitecture arq;
	WorldModel model;
	WorldView  view;
	
	
	private boolean gui = true;
    
	private Logger logger = Logger.getLogger(ClimaProxy.class.getName());
	private Transformer transformer;
	private DocumentBuilder documentbuilder;

	public void setAgId(int i) {
		agId = i;
	}
	
	public ClimaProxy(ClimaArchitecture arq, String host, int port, String username, String password, boolean gui) {
		logger = Logger.getLogger(ClimaProxy.class.getName()+"."+arq.getAgName());
		if (host.startsWith("\"")) {
			host = host.substring(1,host.length()-1);
		}
		setPort(port);
		setHost(host);
		setUsername(username);
		setPassword(password);
        this.gui = gui;
		this.arq = arq;
		try {
			documentbuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
			transformer = TransformerFactory.newInstance().newTransformer();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void processSimulationStart(Element simulation, long currenttime) {
		try {
			simulationID = simulation.getAttribute("id");
			opponent = simulation.getAttribute("opponent");
			arq.addBel(Literal.parseLiteral("opponent("+simulationID+","+opponent+")"));
			
			steps  = Integer.parseInt(simulation.getAttribute("steps"));
			arq.addBel(Literal.parseLiteral("steps("+simulationID+","+steps+")"));
			
			int gsizex = Integer.parseInt(simulation.getAttribute("gsizex"));
			int gsizey = Integer.parseInt(simulation.getAttribute("gsizey"));
			arq.addBel(Literal.parseLiteral("gsize("+simulationID+","+gsizex+","+gsizey+")"));

			int depotx = Integer.parseInt(simulation.getAttribute("depotx"));
			int depoty = Integer.parseInt(simulation.getAttribute("depoty"));			
			arq.addBel(Literal.parseLiteral("depot("+simulationID+","+	depotx+","+depoty+")"));

			// create the model and the view
			model = WorldModel.create(gsizex, gsizey, 4);
            if (gui) view  = WorldView.create(model);
			
			model.setDepot(depotx, depoty);
			logger.fine("Start simulation processed ok!");
		} catch (Exception e) {
			logger.log(Level.SEVERE, "error processing start",e);
		}
	}

	public void processSimulationEnd(Element result, long currenttime) {
		try {
            WorldModel.destroy();
            if (gui) view.destroy();
			arq.remBel(Literal.parseLiteral("opponent(X,Y)"));
			arq.remBel(Literal.parseLiteral("steps(X,Y)"));
			arq.remBel(Literal.parseLiteral("gsize(S,X,Y)"));
			arq.remBel(Literal.parseLiteral("depot(S,X,Y)"));
            String score = result.getAttribute("score") +"-"+ result.getAttribute("result");
            arq.addBel(Literal.parseLiteral("endOfSimulation("+simulationID+","+result.getAttribute("result")+")"));
			logger.fine("End of simulation "+simulationID+": "+score);
		} catch (Exception e) {
			logger.log(Level.SEVERE, "error processing end",e);
		}
	}

    Location lo1 = new Location(-1,-1), 
             lo2 = new Location(-1,-1), 
             lo3 = new Location(-1,-1), 
             lo4 = new Location(-1,-1),
             lo5 = new Location(-1,-1);
    
	public void processRequestAction(Element perception, long currenttime, long deadline) {
        if (agX >= 0) {
            try {
                model.clearAgView(agX, agY);
            } catch (Exception e) {
                logger.log(Level.WARNING, "error clearing ag view",e);                    
            }
        }
		try {
			List perceptions = new ArrayList();
			
			int step = Integer.parseInt(perception.getAttribute("step"));
			agX = Integer.parseInt(perception.getAttribute("posx"));
			agY = Integer.parseInt(perception.getAttribute("posy"));
            
            lo5 = lo4;
            lo4 = lo3;
            lo3 = lo2;
            lo2 = lo1;
            lo1 = new Location(agX,agY);
            
            if (lo1.equals(lo2) && lo2.equals(lo3) && lo3.equals(lo4) && lo4.equals(lo5)) {
                perceptions.add(Literal.parseLiteral("restart"));
            }
            
			model.add(model.ALLY, agX, agY);
			if (agId != -1) {
				model.setAgPos(agId, agX, agY);
			}
			rid = perception.getAttribute("id");
			
			NodeList nl = perception.getElementsByTagName("cell");
			for (int i=0; i < nl.getLength(); i++) {
				Element cell = (Element)nl.item(i);
				String relPos = cell.getAttribute("id");
				int cx=0, cy=0;
				if (relPos.equals("nw")) {
					cx=agX-1; cy=agY-1;
				} else if (relPos.equals("n")) {
					cx=agX; cy=agY-1;
				} else if (relPos.equals("ne")) {
					cx=agX+1; cy=agY-1;
				} else if (relPos.equals("w")) {
					cx=agX-1; cy=agY;
				} else if (relPos.equals("cur")) {
					cx=agX; cy=agY;
				} else if (relPos.equals("e")) {
					cx=agX+1; cy=agY;
				} else if (relPos.equals("sw")) {
					cx=agX-1; cy=agY+1;
				} else if (relPos.equals("s")) {
					cx=agX; cy=agY+1;
				} else if (relPos.equals("se")) {
					cx=agX+1; cy=agY+1;
				}

				NodeList cnl = cell.getChildNodes();
				for (int j=0; j < cnl.getLength(); j++) {
					if (cnl.item(j).getNodeType() == Element.ELEMENT_NODE) {
						// add type
						Element type = (Element)cnl.item(j);
						Term ttype = new Term(type.getNodeName());
						if (type.getNodeName().equals("agent")) {
							ttype.addTerm(new Term(type.getAttribute("type")));
							if (type.getAttribute("type").equals("ally")) {
								model.add(model.ALLY, cx, cy);
							} else if (type.getAttribute("type").equals("enemy")) {
								model.add(model.ENEMY, cx, cy);
							}
						} else if (type.getNodeName().equals("mark")) {
							break; // we are not using marks
							//ttype.addTerm(new StringTermImpl(type.getAttribute("value")));
						} else if (type.getNodeName().equals("unknown")) {
							break; // do not add any perception
						} else if (type.getNodeName().equals("obstacle")) { 
							model.add(model.OBSTACLE, cx, cy);
						} else if (type.getNodeName().equals("gold")) {
							model.add(model.GOLD, cx, cy);
						} else if (type.getNodeName().equals("empty")) {
							model.add(model.EMPTY, cx, cy);
						}

						Literal lcell = new Literal(Literal.LPos, new Pred("cell"));
						
						// add location
						lcell.addTerm(new NumberTermImpl(cx));
						lcell.addTerm(new NumberTermImpl(""+cy));
						
						lcell.addTerm(ttype);
						
						// create perception
						perceptions.add(lcell);
					}
				}
			}

			Literal lpos = new Literal(Literal.LPos, new Pred("pos"));
			//lpos.addTerm(new NumberTermImpl(step));
			lpos.addTerm(new NumberTermImpl(agX));
			lpos.addTerm(new NumberTermImpl(agY));
			//lpos.addTerm(new StringTermImpl(rid));
			perceptions.add(lpos);
			logger.fine("Request action for "+lpos+" / "+rid);
			arq.doPerception(perceptions);
			if (gui) view.update();
		} catch (Exception e) {
			logger.log(Level.SEVERE, "error processing request",e);
		}
	}

	public void send(String action) {
		try {
			logger.fine("sending action "+action+" for step "+rid);
			Document doc = documentbuilder.newDocument();
			Element el_response = doc.createElement("message");
			el_response.setAttribute("type","action");
			doc.appendChild(el_response);

			Element el_action = doc.createElement("action");
			el_action.setAttribute("type", action);
			el_action.setAttribute("id",rid);
			el_response.appendChild(el_action);

			sendDocument(doc);
		} catch (Exception e) {
			logger.log(Level.SEVERE,"parser config error",e);
		}
		
	}
	
}
