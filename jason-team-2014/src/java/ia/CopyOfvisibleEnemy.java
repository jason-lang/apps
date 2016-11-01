package ia;

import java.util.Iterator;
import java.util.Map.Entry;
import graphLib.GlobalGraph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class CopyOfvisibleEnemy extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, final Unifier un, Term[] args) throws Exception {

        final Term termEnemy = args[0];
        final Term termVertex = args[1];
        
        
        return new Iterator<Unifier>() {
            Unifier c = null; // the current response (which is an unifier)
            int id = 1;
            int totalEntities = 28;
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
                while (id <= totalEntities) {
                    while(currentIt.hasNext()) {
                        Entry<String, String> currentEntry = currentIt.next();
                        
                        if (currentEntry.getValue() != null) {
                            c = un.clone();
                            
                            //Term enemy = Literal.parseLiteral(currentEntry.getKey());
                            //Term enemy = VarTerm.parse(currentEntry.getKey());
                            
                            
                            Term enemy;
                            
                            String enemyStr = currentEntry.getKey();
                            if (enemyStr.substring(0, 1).equals(enemyStr.substring(0, 1).toUpperCase())) {
                                enemy = new StringTermImpl(enemyStr);
                            } else {
                                enemy = new Atom(enemyStr);
                            }
                            
                            Atom vertex = new Atom(currentEntry.getValue());
                            
                            //System.out.println(ts.getUserAgArch().getAgName() + "  " + id + " " + " Enemy: " + enemy + " Vertex: " + vertex);
                            
                            if (c.unifiesNoUndo(termEnemy, enemy) && c.unifiesNoUndo(termVertex, vertex)) {
                                return;
                            }
                        }
                    }
                    id++;
                    if (id <= totalEntities)
                        currentIt = GlobalGraph.getInstance().getMapEnemiesFromId().entrySet().iterator();
                    
                    break; //it is not necessary to visit the others anymore
                }
                c = null; // no member is found, 
            }

            public void remove() {}
        };
    }
}
