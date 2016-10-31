package jia;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.Term;
import jason.environment.grid.Location;

import java.util.List;
import java.util.logging.Logger;

import env.WorldModel;

import arch.CowboyArch;
import arch.LocalWorldModel;
import busca.Nodo;

/**
 * Gives the locations for a cownoy to herd a cow.  
 * Use: jia.position_to_one_cow(+X, +Y, -XAg, -YAg)
 * Where: (X,Y) is the position of the Cow and (Xag,Yag) is the position of the agent.
 * @author Gustavo
 *
 */



public class position_to_one_cow extends DefaultInternalAction {
	private static final long serialVersionUID = -4031197537997367939L;
	static Logger logger = null;
	LocalWorldModel model;
	CowboyArch arch;
	@Override
	public Object execute(TransitionSystem ts, Unifier un, Term[] args)
			throws Exception {
		if (logger == null) logger = ts.getLogger();
		
		if(args[0].isNumeric() && args[1].isNumeric()){
			
			int xCow = (int)((NumberTerm)args[0]).solve();
			int yCow = (int)((NumberTerm)args[1]).solve();
			
			Location cowLoc = new Location(xCow,yCow);
			
			arch       = (CowboyArch)ts.getUserAgArch();	
			model = arch.getModel();
			Search s = new Search(model,cowLoc, model.getCorral().center(),null, false, false, false, false, false, false, arch);
			List<Nodo> path = Search.normalPath(s.search());
			int n = path.size();
			
			Location temp;
			if(	path.size()>2){
				temp = Search.getNodeLocation(path.get(n-2));
			}else{
				temp = model.getCorral().center();
			}
			Vec cowPos = new Vec(model, cowLoc);
			Vec tgt = new Vec(model,temp);
			Location agPos = firstFreeLoc(cowPos.sub(tgt), cowPos);
    		return un.unifies(args[2], ASSyntax.createNumber(agPos.x)) 
				&& un.unifies(args[3], ASSyntax.createNumber(agPos.y));
			
		}
		return super.execute(ts, un, args);
	}
	
	private Location firstFreeLoc(Vec displacement, Vec Origin){  
		Location loc = Origin.getLocation(model);
		int maxSize = (int)displacement.r;
		for(int i = 0;i<=maxSize;i++){
			Location temp = (displacement.newMagnitude(i)).add(Origin).getLocation(model);
			if((!model.inGrid(temp)) ||
					model.hasObject(WorldModel.OBSTACLE, temp) || 
					model.hasObject(WorldModel.FENCE, temp) || 
					model.hasObject(WorldModel.SWITCH, temp) || 
					model.hasObject(WorldModel.CORRAL, temp)) {
				
				return loc;
			}
			loc = temp;
		}
		return loc;
	}
	
	
}
