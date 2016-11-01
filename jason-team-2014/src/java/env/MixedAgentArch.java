package env;

import graphLib.GlobalGraph;
import graphLib.Graph;
import jason.architecture.AgArch;
import jason.asSemantics.ActionExec;
import jason.asSemantics.Intention;
import jason.asSemantics.Message;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Atom;
import jason.asSyntax.Literal;
import jason.asSyntax.NumberTerm;
import jason.asSyntax.StringTerm;
import jason.asSyntax.Term;
import jason.asSyntax.parser.ParseException;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Queue;
import java.util.Set;

public class MixedAgentArch extends AgArch implements AgentListenerEvents {
    private Graph graph = new Graph();
    private GlobalGraph globalGraph = GlobalGraph.getInstance();
    private Literal[] lastPercepts = null;
    private ActionExec actionFullMap = new ActionExec(Literal.parseLiteral("recharge"), new Intention());
    private int lastNumberPercept = 0;
    private Set<String> jasonEnvActions = new HashSet<String>();
    private ResultLogger resultLogger = new ResultLogger();
    private boolean logOn = false; 
    
    @Override
    public void init() throws Exception {
        jasonEnvActions.add("skip");
        jasonEnvActions.add("goto");
        jasonEnvActions.add("probe");
        jasonEnvActions.add("survey");
        jasonEnvActions.add("buy");
        jasonEnvActions.add("recharge");
        jasonEnvActions.add("attack");
        jasonEnvActions.add("repair");
        jasonEnvActions.add("parry");
        jasonEnvActions.add("inspect");
        super.init();
        
        CustomEISEnv.addAgentListenerEvents(getAgName(), this);
        
        logOn = getAgName().equals("explorer1");
    }
    
    public Graph getGraph() {
        return graph;
    }

    public boolean isLogOn() {
    return logOn;
    }
    
    public void newGraph() {
        graph = new Graph();
    }
    
    public List<Literal> perceive() {
        super.perceive(); //run CArtAgO percepts
        List<Literal> newPercepts = getArchInfraTier().perceive();
        boolean fullmap = false;
        Literal lSimEnd = null;
        if (lastPercepts != null) {
            
            fullmap = lastPercepts.length > 800;
            if (fullmap) {
                act(actionFullMap, null);
            }
            
            int maxEdges = graph.getMaxEdges();
            int currentEdges = graph.getEdges();
            
            if (!fullmap || (fullmap && currentEdges < maxEdges && lastNumberPercept != lastPercepts.length)) {
                
                graph.resetTeamsVertice();
                
                newPercepts = new ArrayList<Literal>();
                
                String functor;
                Literal lPerceptStep = null;
                for (Literal l : lastPercepts) {
                    functor = l.getFunctor();
                    
                    if (functor.equals("visibleEdge")) {
                        if (currentEdges < maxEdges) {
                            List<Term> terms = l.getTerms();
                            graph.addEdge(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor(), Graph.MAXWEIGHT);
                            globalGraph.addEdge(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor(), Graph.MAXWEIGHT);
                        }
                        continue;
                    } else if (functor.equals("surveyedEdge")) {
                        List<Term> terms = l.getTerms();
                        graph.addEdge(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor(),  (int) ((NumberTerm) terms.get(2)).solve());
                        globalGraph.addEdge(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor(),  (int) ((NumberTerm) terms.get(2)).solve());
                        continue;
                    } else if (functor.equals("visibleVertex")) {
                        List<Term> terms = l.getTerms();
                        if (terms.get(1) instanceof Atom) {
                            graph.addVertex(((Atom) terms.get(0)).getFunctor(), ((Atom) terms.get(1)).getFunctor());
                        } else {
                            graph.addVertex(((Atom) terms.get(0)).getFunctor(), ((StringTerm) terms.get(1)).getString());
                        }
                        continue;
                    } else if (functor.equals("vertices")) {
                        graph.setMaxVertices((int)((NumberTerm) l.getTerm(0)).solve());
                    } else if (functor.equals("edges")) {
                        graph.setMaxEdges((int)((NumberTerm) l.getTerm(0)).solve());
                    } else if (functor.equals("step")) {
                        lPerceptStep = l;
                        
                        if (logOn) {
                            List<Term> terms = l.getTerms();
                            NumberTerm value = (NumberTerm) terms.get(0);
                            if (((int) value.solve()) >= 100 && ((int) value.solve()) <= 105) {
                                resultLogger.reset();
                                resultLogger.setGraph(graph);
                            }
                        }
                        continue;
                    } else if (functor.equals("simEnd")) {
                        lSimEnd = l;
                        continue;                       
                    } else if (logOn && functor.equals("id")) {
                        List<Term> terms = l.getTerms();
                        NumberTerm value = (NumberTerm) terms.get(0);
                        resultLogger.setSeed((long)value.solve());
                    } else if (logOn && functor.equals("score")) {
                        List<Term> terms = l.getTerms();
                        NumberTerm value = (NumberTerm) terms.get(0);
                        resultLogger.setScore((int)value.solve());
                    } else if (logOn && functor.equals("ranking")) {
                        List<Term> terms = l.getTerms();
                        NumberTerm value = (NumberTerm) terms.get(0);
                        resultLogger.setRanking((int)value.solve());
                    }
                    newPercepts.add(l);
                }
                if (lPerceptStep != null) {
                    newPercepts.add(lPerceptStep);
                }
                if (lSimEnd != null) {
                    newPercepts.add(0, lSimEnd);
                    if (logOn) {
                        resultLogger.addValues();
                        resultLogger.commitLine();
                    }
                }
                lastNumberPercept = lastPercepts.length;
            }
            lastPercepts = null;
        }
        
        if (fullmap) {
            return null;
        } else {
            return newPercepts;
        }
    }
    
    @Override
    public void checkMail() {
        super.checkMail(); 
        
        Queue<Message> mbox = getTS().getC().getMailBox();
        Iterator<Message> i = mbox.iterator();
        
        while (i.hasNext()) {
            Message im = i.next();
            
            if (im.getPropCont().toString().startsWith("probedVertex")) {
                
                i.remove();
                Literal l = null;
                if (im.getPropCont() instanceof Literal)
                    l = (Literal)im.getPropCont();
                else
                    try {
                        l = ASSyntax.parseLiteral(im.getPropCont().toString());
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }                   
                Atom vertexV = (Atom) l.getTerm(0);
                NumberTerm value = (NumberTerm) l.getTerm(1);
                
                graph.setVertexValue(vertexV.getFunctor(), (int)value.solve());
            } else if (im.getPropCont().toString().startsWith("visitedVertex")) {
                i.remove();
                Literal l = null;
                if (im.getPropCont() instanceof Literal)
                    l = (Literal)im.getPropCont();
                else
                    try {
                        l = ASSyntax.parseLiteral(im.getPropCont().toString());
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }                 
                Atom vertexV = (Atom) l.getTerm(0);
                NumberTerm step = (NumberTerm) l.getTerm(1);
                
                graph.setVertexVisited(vertexV.getFunctor(), (int)step.solve());                    
            }
        }
    }
    
    /** Send specific actions to Jason environment */
    @Override
    public void act(ActionExec act, List<ActionExec> fb) {
        if (jasonEnvActions.contains(act.getActionTerm().getFunctor())) {
            getArchInfraTier().act(act, fb); // uses the centralised ag arch
        } else {
            super.act(act, fb); // uses cartago ag arch
        }
    }
    
    public void notifyPercepts(Literal... percepts) {
        lastPercepts = percepts;
        getArchInfraTier().wake();
    }

    public void addBelief(Literal belief) {
        getTS().getAg().getBB().add(belief);
    }

}
