// Internal action code for project smadasMAPC2012

package ia;

import java.util.Iterator;
import java.util.List;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class vertex extends DefaultInternalAction {
    @Override
    public Object execute(TransitionSystem ts, final Unifier un, Term[] args) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        final Graph graph = arch.getGraph();
        
        final Term vertex = args[0];
        if (vertex.isAtom()) {
            Term teamTerm;
            String result = graph.getTeamAtVertex(((Atom) vertex).getFunctor());
            if (result.equals("none")) {
                teamTerm = new Atom(result);
            } else {
                teamTerm = new StringTermImpl(result);
            }
            
            return un.unifiesNoUndo(args[1], teamTerm);
        } else {
            System.out.println("AQUI NO!");
            return new Iterator<Unifier>() {
                Unifier c = null; // the current response (which is an unifier)
                List<String> list = graph.getAllVertices();
                int index = 0;
                
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
                    while (index < list.size()) {
                        c = un.clone();
                        
                        Atom vertexV = new Atom(list.get(index));
                        if (c.unifiesNoUndo(vertex, vertexV)) {
                            index++;
                            return;
                        }
                        index++;
                    }
                    c = null; // no member is found, 
                }
                
                public void remove() { }
                
            };
        }
    }
}
