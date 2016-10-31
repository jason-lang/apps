package testbed.participants;

import jason.architecture.AgArch;
import jason.asSemantics.ActionExec;
import jason.asSemantics.Agent;
import jason.asSemantics.Message;
import jason.asSemantics.TransitionSystem;
import jason.asSyntax.Literal;
import jason.bb.ChainBB;
import jason.bb.IndexedBB;
import jason.infra.centralised.CentralisedAgArch;
import jason.infra.centralised.RunCentralisedMAS;
import jason.mas2j.ClassParameters;
import jason.runtime.Settings;
import jason.util.asl2xml;

import java.io.File;
import java.io.FileWriter;
import java.util.List;

/**
 * This class implements the agent architecture that links 
 * the agent speak code to the ART environment.
 * 
 * @author hubner
 */
public class JasonARTAgent extends CentralisedAgArch {

    private boolean inSleep = false;
    private Agent ag;
    private TransitionSystem ts;

    private JasonARTWrapper wrapper;
    
    public JasonARTAgent(JasonARTWrapper w, String name, String src) {
        // set up the Jason agent
        try {
            setAgName(name);
            /*
            ClassParameters bbclass = new ClassParameters(TimedBB.class.getName());
            bbclass.addParameter("certainty(key,key,_)");
            bbclass.addParameter("image(key,key,_)");
            bbclass.addParameter("sincere(key)");
            bbclass.addParameter("opinions_count(key,_,_)");
            */
            
            ClassParameters bbclass = new ClassParameters(ChainBB.class.getName());
            bbclass.addParameter(TimedBB.class.getName());
            bbclass.addParameter(IndexedBB.class.getName()+"(\"certainty(key,key,_)\", \"image(key,key,_)\", \"sincere(key)\", \"opinions_count(key,_,_)\")");
            
            initAg( AgArch.class.getName(), // arch class 
                    Agent.class.getName(),  // agent class
                    bbclass, // belief base class 
                    src,  // source code
                    new Settings(), // settings
                    null); // runtime launcher
            ts = getUserAgArch().getTS();
            ag = ts.getAg();
            wrapper = w;
            RunCentralisedMAS.setupDefaultConsoleLogger();
            setLogger();
        } catch (Exception e) {
            System.err.println("Init error: "+e);
            e.printStackTrace();
        }
    }
    
    public Agent getAg() {
        return ag;
    }
    
    public TransitionSystem getTS() {
        return ts;
    }
    
    /** special kind of run: runs until the agent enters in sleep mode (nothing else to do) */
    @Override
    public void run() {
        inSleep = false;
        while (!inSleep) {
            // calls the Jason engine to perform one reasoning cycle
            getUserAgArch().getTS().reasoningCycle();
        }
    }

    @Override
    public boolean isRunning() {
        return true;
    }

    @Override
    public void sleep() {
        inSleep = true;
    }
    
    @Override
    public void wake() {
        inSleep = false;
    }

    @Override
    public void sendMsg(Message m)  {
        wrapper.sendJasonMsg(m);
    }

    @Override
    public void broadcast(Message m) throws Exception {
        System.err.println("broadcast is not implemented for ART.");
    }

    private List<Literal> tmpperc;
    public void setPercepts(List<Literal> p) {
        tmpperc = p;
    }
    @Override
    public List<Literal> perceive() {
        List<Literal> t = tmpperc;
        tmpperc = null;
        return t;
    }

    @Override
    public void act(ActionExec action, List<ActionExec> feedback) {
        System.err.println("actions are not implemented for ART.");
    }

    private String dumpDir = null;
    private int    dumpCount = 0;
    public void setDumpDirectory(String path) {
        dumpDir = path;
        File f = new File(dumpDir);
        if (!f.exists())
            f.mkdirs();
    }
    
    public void dumpMind() {
        if (dumpDir == null)
            return;
        try {
            asl2xml transformer = new asl2xml();
            
            String agmind = transformer.transform(getAg().getAgState());
            String filename = String.format("%5d.xml", (dumpCount++)).replaceAll(" ","0");
            FileWriter outmind = new FileWriter(new File(dumpDir+"/"+filename));
            outmind.write(agmind);
            outmind.close();
        } catch (Exception e) {
            System.out.println("error getting agent status "+e);                            
        }
    }
}
