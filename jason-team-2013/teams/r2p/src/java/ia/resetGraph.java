package ia;

import env.ContestLogger;
import env.MixedAgentArch;
import graphLib.GlobalGraph;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class resetGraph extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
        MixedAgentArch arch = (MixedAgentArch)ts.getUserAgArch();
        
        arch.newGraph();
        GlobalGraph.getInstance().reset();
        ContestLogger.getInstance().reset();
        
        return true;
    }
}
