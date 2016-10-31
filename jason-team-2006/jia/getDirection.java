package jia;

import jason.asSemantics.InternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jasonteam.Location;
import jasonteam.WorldModel;
import jasonteam.WorldView;

import java.util.ArrayList;
import java.util.List;

import busca.AEstrela;
import busca.Busca;
import busca.BuscaIterativo;
import busca.Estado;
import busca.Heuristica;
import busca.Nodo;

public class getDirection implements InternalAction {
	
	public boolean execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
		try {
            String sAction = "skip";

            WorldModel model = WorldModel.get();
	
			NumberTerm agx = (NumberTerm)terms[0].clone(); un.apply((Term)agx);
			NumberTerm agy = (NumberTerm)terms[1].clone(); un.apply((Term)agy);
			NumberTerm tox = (NumberTerm)terms[2].clone(); un.apply((Term)tox);
			NumberTerm toy = (NumberTerm)terms[3].clone(); un.apply((Term)toy);
			int iagx = (int)agx.solve();
			int iagy = (int)agy.solve();
			int itox = (int)tox.solve();
			int itoy = (int)toy.solve();
			if (itox < model.getWidth() && itoy < model.getHeight()) {
    			AEstrela searchAlg = new AEstrela();
    			searchAlg.setQuieto(true);
    			searchAlg.setMaxAbertos(1000);
    			//System.out.println("-- from "+iagx+","+iagy+" to "+tox+","+toy);
    			Nodo solution = searchAlg.busca(new MinerState(new Location(iagx, iagy), new Location(itox, itoy), model, "initial"));
    			if (solution == null) {
    				solution = searchAlg.getTheBest();
    			}
    			Nodo root = solution;
    			Estado prev1 = null;
    			Estado prev2 = null;
    			while (root != null) {
    				prev2 = prev1;
    				prev1 = root.getEstado();
    				root = root.getPai();
    			}
    			if (prev2 != null) {
    				//System.out.println("-- "+solution.montaCaminho());
    				sAction =  ((MinerState)prev2).op;
    			} 
            }
			return un.unifies(terms[4], new Term(sAction));
		} catch (Throwable e) {
			e.printStackTrace();
			return false;
		}
	}

	// just for testing 
	public static void main(String[] a) {
        //WorldModel model = m1();
		//MinerState initial = new MinerState(new Location(19, 17), new Location(5, 7), model, "initial");
        WorldModel model = m2();
        MinerState initial = new MinerState(new Location(6, 26), new Location(20,21), model, "initial");
        ///20,21
        AEstrela searchAlg = new AEstrela(); 
        searchAlg.setMaxAbertos(1000);
		searchAlg.setQuieto(false);
		Nodo solution = searchAlg.busca(initial);
        if (solution == null) {
            solution = searchAlg.getTheBest();
            System.out.println("The best i can="+solution.montaCaminho()+ "\ncost ="+solution.g());
        } else {
            System.out.println("Path="+solution.montaCaminho()+ "\ncost ="+solution.g());
        }
		Nodo root = solution;
		Estado prev1 = null;
		Estado prev2 = null;
		while (root != null) {
			prev2 = prev1;
			prev1 = root.getEstado();
			root = root.getPai();
		}
		System.out.println("Action = "+ ((MinerState)prev2).op);
	}

    private static WorldModel m1() {
        WorldModel model = WorldModel.create(100,100,4);
        model.add(WorldModel.OBSTACLE, 1,1);
        model.add(WorldModel.OBSTACLE, 2,1);
        model.add(WorldModel.OBSTACLE, 2,2);

        model.add(WorldModel.EMPTY, 2,0);
        model.add(WorldModel.EMPTY, 3,0);
        model.add(WorldModel.EMPTY, 3,1);
        model.add(WorldModel.EMPTY, 3,2);
        return model;
    }
    private static WorldModel m2() {
        WorldModel model = WorldModel.create(35,35,4);
        model.setDepot(16,16);
        //model.setAgPos(0, 1, 0);
        //model.setAgPos(1, 20, 0);
        model.setAgPos(2, 6, 26);
        //model.setAgPos(3, 20, 20);
        
        model.add(WorldModel.GOLD, 20,13);
        model.add(WorldModel.GOLD, 15,20);
        model.add(WorldModel.GOLD, 1,1);
        model.add(WorldModel.GOLD, 3,5);
        model.add(WorldModel.GOLD, 24,24);
        model.add(WorldModel.GOLD, 20,20);
        model.add(WorldModel.GOLD, 20,21);
        model.add(WorldModel.GOLD, 2,22);
        model.add(WorldModel.GOLD, 2,23);
        model.add(WorldModel.GOLD, 6,24);
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
        //WorldView view = WorldView.create(model);
        //view.update();
        return model;
    }
}


class MinerState implements Estado, Heuristica {

	// State information
	Location pos; // current location
	Location to;
	String op;
	int cost;
	WorldModel model;
	
	public MinerState(Location l, Location to, WorldModel model, String op) {
		this.pos = l;
		this.to = to;
		this.model = model;
		this.op = op;
		this.cost = 3;
		if (model.isUnknown(l)) this.cost = 2; // unknown places are preferable
	}
	
	public int custo() {
		return cost;
	}

	public boolean ehMeta() {
		return pos.equals(to);
	}

	public String getDescricao() {
		return "Jason team miners search";
	}

	public int h() {
		return pos.distance(to) * 3;
	}

	public List sucessores() {
		List s = new ArrayList(4);
		// four directions
		suc(s,new Location(pos.x,pos.y-1),"up");
		suc(s,new Location(pos.x,pos.y+1),"down");
		suc(s,new Location(pos.x-1,pos.y),"left");
		suc(s,new Location(pos.x+1,pos.y),"right");
        //System.out.println(pos+"/"+hashCode()+"="+s);
		return s;
	}
	
	private void suc(List s, Location newl, String op) {
		if (model.isFree(newl) || (newl.equals(to) && model.isFreeOfObstacle(newl))) {
			s.add(new MinerState(newl,to,model,op));
		}
	}
	
    public boolean equals(Object o) {
        try {
            MinerState m = (MinerState)o;
            return pos.equals(m.pos);
        } catch (Exception e) {}
        return false;
    }
    
    public int hashCode() {
        return pos.toString().hashCode();
    }
            
	public String toString() {
		return "(" + pos + "-" + op + "/" + cost + ")"; 
	}
}
