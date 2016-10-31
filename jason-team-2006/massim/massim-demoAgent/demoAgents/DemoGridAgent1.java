package demoAgents;

import java.util.Random;

import massim.AbstractAgent;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * This class is a demoAgent for the simulation.
 * @author Michael Köster
 *
 */
public class DemoGridAgent1 extends AbstractAgent {
	private boolean agentHoldsGold = false;
	private Integer depotx = 0, depoty = 0;

	/**
	 * This method creates a DemoGridAgent1.
	 * @param args Username, Passwort and optional Host
	 */
	public static void main(String[] args) {
		//basic configuration settings
		DemoGridAgent1 demoagent = new DemoGridAgent1();
		demoagent.setPort(12300);
		if (args.length == 3) {
			demoagent.setHost(args[2]);
		} else {
			demoagent.setHost("localhost");
		}
		demoagent.setUsername(args[0]);
		demoagent.setPassword(args[1]);
		demoagent.start();
	}

	/* (non-Javadoc)
	 * @see massim.AbstractAgent#processRequestAction(org.w3c.dom.Element, org.w3c.dom.Element, long, long)
	 */
	public void processRequestAction(Element perception, Element target,
			long currenttime, long deadline) {
//		react to normal perception, modify target so that it becomes a valid action
		Random r1 = new Random();
		String action = "";
		
		//handle perception
		//determine current position
		int posx = Integer.parseInt(perception.getAttribute("posx"));
		int posy = Integer.parseInt(perception.getAttribute("posy"));
		//determine current cell
		NodeList cells = perception.getElementsByTagName("cell");
		Node cell = cells.item(0);
		Element el_cell = (Element) cell; 
		if (el_cell.getAttribute("id").equals("cur")) {
			NodeList cg = perception.getElementsByTagName("gold");
			NodeList cd = perception.getElementsByTagName("depot");
			//gold found
			for (int i = 0; i < cg.getLength(); i++) {
				if (cg.item(i).getParentNode().equals(cell) && !agentHoldsGold) {
					action = "pick";
					agentHoldsGold = true;
				}
			}
			//depot found
			for (int i = 0; i < cd.getLength(); i++) {
				if (cd.item(i).getParentNode().equals(cell) && agentHoldsGold) {
					action = "drop";
					agentHoldsGold = false;
				}
			}
			
		}
		//go to depot
		if (agentHoldsGold && action.equals("")) {
			if (posx - depotx < 0) {
				action = "right";
			} else if (posx - depotx > 0) {
				action = "left";
			} else if (posy - depoty > 0) {
				action = "up";
			} else if (posy - depoty < 0) {
				action = "down";
			}
		}
		//calculate action
		if (action.equals("")) {
			int actionNr = Math.abs(r1.nextInt()) % 7;
			switch (actionNr) {
			case 0:
				action = "up";
				break;
			case 1:
				action = "down";
				break;
			case 2:
				action = "left";
				break;
			case 3:
				action = "right";
				break;
			case 4:
				action = "unmark";
				break;
			case 5:
				action = "skip";
				break;
			case 6:
				action = "mark";
				target.setAttribute("param", "bla");
			}
		}
		//add action to xml-document
		target.setAttribute("type", action);
	}
	
	
	

	/* (non-Javadoc)
	 * @see massim.AbstractAgent#processLogIn()
	 */
	public void processLogIn() {
		//called as soon as agent logged in successfully
		//TODO: insert code here
		//Note: This is a good place to do a ping
	}
	
	/* (non-Javadoc)
	 * @see massim.AbstractAgent#processPong(java.lang.String)
	 */
	public void processPong(String pong) {
		//react on incoming pong
		//TODO: insert code here
	}

	/* (non-Javadoc)
	 * @see massim.AbstractAgent#processSimulationEnd(org.w3c.dom.Element, long, long)
	 */
	public void processSimulationEnd(Element perception, long currenttime) {
		//react on simulation end
		//TODO: insert code here
	}

	public void processSimulationStart(Element perception, long currenttime) {
		//react on simulation Start
		depotx = Integer.parseInt(perception.getAttribute("depotx"));
		depoty = Integer.parseInt(perception.getAttribute("depoty"));
	}
}