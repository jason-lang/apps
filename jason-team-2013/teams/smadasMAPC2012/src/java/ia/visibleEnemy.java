package ia;

import java.util.Iterator;
import java.util.Map.Entry;
import java.util.Set;

import graphLib.GlobalGraph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class visibleEnemy extends DefaultInternalAction {

    @Override
    public Object execute(final TransitionSystem ts, final Unifier un, Term[] args) throws Exception {

        final Term termEnemy = args[0];
        final Term termVertex = args[1];
        
        
        if (termEnemy.isAtom() || termEnemy.isString()) {
        	String vertex = GlobalGraph.getInstance().getEnemyPosition(unQuote(termEnemy.toString()));
        	
        	if (vertex == null) {
        		return false;
        	} else {
        		return un.unifiesNoUndo(args[1], new Atom(vertex));
        	}
        } else if (termVertex.isAtom()) {
        	final Set<String> verticesEnemyPosition = GlobalGraph.getInstance().getMapEnemiesByPosition(((Atom) termVertex).getFunctor());
        	
        	if (verticesEnemyPosition == null)
        		return false;
        	
	        return new Iterator<Unifier>() {
	            Unifier c = null; // the current response (which is an unifier)
	            Iterator<String> currentIt = verticesEnemyPosition.iterator();
	            
	            
	            public boolean hasNext() {
	                if (c == null) // the first call of hasNext should find the first response 
	                    find();
	                return c != null;
	            }
	
	            public Unifier next() {
	                if (c == null) find();
	                Unifier b = c;
	                find(); // find next response
	                return b;
	            }
	            
	            void find() {
	        		while(currentIt.hasNext()) {
	        			String enemyStr = currentIt.next();
	        			
	        			if (enemyStr != null) {
		            		c = un.clone();
		            		
		            		Term enemy;
		            		if (enemyStr.substring(0, 1).equals(enemyStr.substring(0, 1).toUpperCase())) {
		            			enemy = new StringTermImpl(enemyStr);
		            		} else {
		            			enemy = new Atom(enemyStr);
		            		}
		            		
		            		if (c.unifiesNoUndo(termEnemy, enemy)) {
		            			return;
		            		}
	        			}
	        		}
	                c = null; // no member is found, 
	            }
	            public void remove() {}
	        };
        } else {
	        Iterator<Entry<String,String>> teste = GlobalGraph.getInstance().getMapEnemiesFromId().entrySet().iterator();
	        
	        return new Iterator<Unifier>() {
	            Unifier c = null; // the current response (which is an unifier)
	            Iterator<Entry<String,String>> currentIt = GlobalGraph.getInstance().getMapEnemiesFromId().entrySet().iterator();
	            
	            
	            public boolean hasNext() {
	                if (c == null) // the first call of hasNext should find the first response 
	                    find();
	                return c != null;
	            }
	
	            public Unifier next() {
	                if (c == null) find();
	                Unifier b = c;
	                find(); // find next response
	                return b;
	            }
	            
	            void find() {
	        		while(currentIt.hasNext()) {
	        			Entry<String, String> currentEntry = currentIt.next();
	        			
	        			if (currentEntry.getValue() != null) {
		            		c = un.clone();
		            		
		            		Term enemy;
		            		
		            		String enemyStr = currentEntry.getKey();
		            		if (enemyStr.substring(0, 1).equals(enemyStr.substring(0, 1).toUpperCase())) {
		            			enemy = new StringTermImpl(enemyStr);
		            		} else {
		            			enemy = new Atom(enemyStr);
		            		}
		            		
		            		Atom vertex = new Atom(currentEntry.getValue());
		            		
		            		//System.out.println(ts.getUserAgArch().getAgName() + " " + " Enemy: " + enemy + " Vertex: " + vertex);
		            		
		            		if (c.unifiesNoUndo(termEnemy, enemy) && c.unifiesNoUndo(termVertex, vertex)) {
		            			return;
		            		}
	        			}
	        		}
	                c = null; // no member is found, 
	            }
	            public void remove() {}
	        };
        }
    }
    
    private String unQuote(String str) {
    	if (str.charAt(0) == '"' && str.charAt(str.length()-1) == '"' )
            return str.substring(1, str.length()-1);
    	return str;
    }
}
