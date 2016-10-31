package jia;

import jason.asSemantics.InternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jasonteam.ClimaArchitecture;
import jasonteam.WorldModel;

import java.util.ArrayList;
import java.util.List;

import busca.AEstrela;
import busca.Busca;
import busca.BuscaIterativo;
import busca.BuscaLargura;
import busca.Estado;
import busca.Heuristica;
import busca.Nodo;

public class getDirection implements InternalAction {
	
	int itox, itoy;
	WorldModel model;
	
	public boolean execute(TransitionSystem ts, Unifier un, Term[] terms) throws Exception {
		try {
			model = getClimaArch(ts).getModel();
	
			NumberTerm agx = (NumberTerm)terms[0].clone(); un.apply((Term)agx);
			NumberTerm agy = (NumberTerm)terms[1].clone(); un.apply((Term)agy);
			NumberTerm tox = (NumberTerm)terms[2].clone(); un.apply((Term)tox);
			NumberTerm toy = (NumberTerm)terms[3].clone(); un.apply((Term)toy);
			int iagx = (int)agx.solve();
			int iagy = (int)agy.solve();
			itox = (int)tox.solve();
			itoy = (int)toy.solve();
	
			AEstrela searchAlg = new AEstrela();
			searchAlg.setQuieto(true);
			//searchAlg.setMaxF(20);
			//System.out.println("-- from "+iagx+","+iagy+" to "+tox+","+toy);
			Nodo solution = searchAlg.busca(new MinerState(iagx, iagy, this, "initial"));
			//if (solution == null) {
			//	solution = searchAlg.getTheBest();
			//}
			Nodo root = solution;
			Estado prev1 = null;
			Estado prev2 = null;
			while (root != null) {
				prev2 = prev1;
				prev1 = root.getEstado();
				root = root.getPai();
			}
			String sAction = "skip";
			if (prev2 != null) {
				//System.out.println("-- "+solution.montaCaminho());
				sAction =  ((MinerState)prev2).op;
			} 
	
			
			/*
			Term action;
			if (iagx < itox) { 
				action = new Term("right"); 
			} else if (iagx > itox) {
				action = new Term("left");
			} else if (iagy < itoy) {
				action = new Term("down");
			} else {
				action = new Term("up");
			}
			*/
			
			return un.unifies(terms[4], new Term(sAction));
		} catch (Throwable e) {
			e.printStackTrace();
			return false;
		}
	}

	ClimaArchitecture getClimaArch(TransitionSystem myTS) {
		if (myTS != null && myTS.getUserAgArch() instanceof ClimaArchitecture) {
			return (ClimaArchitecture)myTS.getUserAgArch();
		}
		return null;
	}
	
	// just for testing 
	public static void main(String[] a) {
		getDirection ia = new getDirection();
		ia.itox = 80;
		ia.itoy = 80;
		ia.model = WorldModel.create(100,100);
		ia.model.add(WorldModel.OBSTACLE, 1,1);
		ia.model.add(WorldModel.OBSTACLE, 2,1);
		ia.model.add(WorldModel.OBSTACLE, 2,2);
		//ia.model.add(WorldModel.OBSTACLE, 3,1);

		ia.model.add(WorldModel.EMPTY, 2,0);
		ia.model.add(WorldModel.EMPTY, 3,0);
		ia.model.add(WorldModel.EMPTY, 3,1);
		ia.model.add(WorldModel.EMPTY, 3,2);
		
		MinerState initial = new MinerState(0, 3, ia, "initial");
		AEstrela searchAlg = new AEstrela();
		searchAlg.setQuieto(false);
		Nodo solution = searchAlg.busca(initial);
		System.out.println("Path="+solution.montaCaminho()+ "\ncost ="+solution.g());
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
	
}


class MinerState implements Estado, Heuristica {

	// State information
	int x,y;
	getDirection ia;
	String op;
	int cost;
	
	public MinerState(int x, int y, getDirection ia, String op) {
		this.x = x;
		this.y = y;
		this.ia = ia;
		this.op = op;
		this.cost = 3;
		if (ia.model.isUnknown(x,y)) this.cost = 2; // unknown places are preferable
	}
	
	public int custo() {
		return cost;
	}

	public boolean ehMeta() {
		return x == ia.itox && y == ia.itoy;
	}

	public String getDescricao() {
		return "Jason team miners search";
	}

	public int h() {
		return (Math.abs(x - ia.itox) + Math.abs(y - ia.itoy)) * 3;
	}

	public List sucessores() {
		List s = new ArrayList(4);
		// four directions
		if (ia.model.isFree(x,y-1)) {
			s.add(new MinerState(x,y-1,ia,"up"));
		}
		if (ia.model.isFree(x,y+1)) {
			s.add(new MinerState(x,y+1,ia,"down"));
		}
		if (ia.model.isFree(x-1,y)) {
			s.add(new MinerState(x-1,y,ia, "left"));
		}
		if (ia.model.isFree(x+1,y)) {
			s.add(new MinerState(x+1,y,ia, "right"));
		}
		//System.out.println(this + " suc is "+s);
		return s;
	}
	
	public String toString() {
		return "(" + x + "," + y + "-" + op + "/" + cost + ")"; 
	}
}
