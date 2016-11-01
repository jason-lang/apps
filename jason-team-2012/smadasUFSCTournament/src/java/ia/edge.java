// Internal action code for project smadasMAPC2012

package ia;

import java.util.Iterator;

import env.MixedAgentArch;
import graphLib.Graph;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class edge extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, final Unifier un, Term[] args) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        final Graph graph = arch.getGraph();
        
        final Atom vertexU = (Atom) args[0];
        final int gradeU = graph.getGrade(vertexU.getFunctor());
        
        final Term termVertexV = args[1];
        final Term termWeight = args[2];
        
        return new Iterator<Unifier>() {
            Unifier c = null; // the current response (which is an unifier)
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
                while (index < gradeU) {
                    c = un.clone();
                    
                    Atom vertexV = new Atom(graph.getAdj(vertexU.getFunctor(), index));
                    NumberTerm weight = new NumberTermImpl(graph.getWeight(vertexU.getFunctor(), index));
                    if (c.unifiesNoUndo(termVertexV, vertexV) && c.unifiesNoUndo(termWeight, weight)) {
                        index++;
                        return;
                    }
                    index++;
                }
                c = null; // no member is found, 
            }

            public void remove() {}
        };
    }
}
