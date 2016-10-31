package arch;

import jason.environment.grid.Location;
import jason.util.asl2xml;

import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import env.WorldModel;

public class WriteStatusThread extends Thread {

    protected Logger logger = Logger.getLogger(WriteStatusThread.class.getName());

    // singleton
    static  WriteStatusThread instance = null;
    private WriteStatusThread() {}
    
    public static WriteStatusThread create(CowboyArch owner) { 
        if (instance == null) {
            instance = new WriteStatusThread();
            instance.owner = owner;
            instance.start();
        }
        return instance;
    }    
    public static boolean isCreated() {
        return instance != null;
    }
    
    private CowboyArch owner = null; 
    
    private static CowboyArch[] agents = new CowboyArch[WorldModel.agsByTeam];

    public static void registerAgent(String name, CowboyArch arch) {
        agents[arch.getMyId()] = arch;
    }
    
    Map<Integer,List<Location>> locations;
    
    public void reset() {
        // init locations
        locations = new HashMap<Integer, List<Location>>();
        for (int i=0; i<WorldModel.agsByTeam; i++) {
            locations.put(i, new LinkedList<Location>());
        }
    }
    
    public void run() {
        reset();
        
        String fileName = "world-status.txt";
        
        PrintWriter out = null;
        try {
            asl2xml transformer = new asl2xml();
            
            out = new PrintWriter(fileName);
            PrintWriter map = new PrintWriter("map-status.txt");
            while (true) {
                try {
                    // write map
                    map.println("\n\n** Agent "+owner.getAgName()+" in cycle "+owner.getSimStep()+"\n");
                    //for (int i=0; i<model.getNbOfAgs(); i++) {
                        // out.println("miner"+(i+1)+" is carrying "+model.getGoldsWithAg(i)+" gold(s), at "+model.getAgPos(i));
                    //}
                    map.println(owner.getModel().toString());
                    map.flush();
                    
                    // write location of the agents
                    long timebefore = System.currentTimeMillis();
                    waitNextCycle();
                    long cycletime = System.currentTimeMillis() - timebefore;
                    
                    StringBuilder s = new StringBuilder(String.format("Step %5d : ", owner.getSimStep()-1));
                    for (int agId=0; agId<WorldModel.agsByTeam; agId++) {
                        if (agents[agId] != null) {
                            Location agp = agents[agId].getLastLocation();
                            if (agp != null) {
                                // count how long the agent is in the same location
                                int c = 0;
                                Iterator<Location> il = locations.get(agId).iterator();
                                while (il.hasNext() && il.next().equals(agp) && c <= 11) {
                                    c++;
                                }
                                String sc = "*";
                                if (c < 10) sc = ""+c;
                                
                                locations.get(agId).add(0,agp);
                                String lastAct = shortActionFormat(agents[agId].getLastAction());
                                s.append(String.format("%5d,%2d/%s %s", agp.x, agp.y, sc, lastAct));
                            }
                        }
                    }
                    
                    s.append( String.format("%7d ms", cycletime));
                    logger.info(s.toString());
                    out.println(s.toString());
                    out.flush();
                    
                    
                    // store the agents' mind
                    for (CowboyArch arch : agents) {
            if (arch == null) break;
                        try {
                            File dirmind = new File("mind-ag/"+arch.getAgName());
                            if (!dirmind.exists())
                                dirmind.mkdirs();
                            String agmind = transformer.transform(arch.getTS().getAg().getAgState());
                            String filename = String.format("%5d.xml",arch.getSimStep()).replaceAll(" ","0");
                            FileWriter outmind = new FileWriter(new File(dirmind+"/"+filename));
                            outmind.write(agmind);
                            outmind.close();
                        } catch (Exception e) {
                            System.out.println("error getting agent status "+e);                            
                        }
                    }
                    
                } catch (InterruptedException e) { // no problem, quit the thread
                    return;
                } catch (Exception e) {
                    System.out.println("error in writing status "+e);
                    sleep(1000);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            out.close();                
        }
    }
    
    public String shortActionFormat(String act) {
        if (act == null) return "  ";
        if (act.equals(WorldModel.Move.east.toString()))        return "e ";
        if (act.equals(WorldModel.Move.northeast.toString()))   return "ne";
        if (act.equals(WorldModel.Move.southeast.toString()))   return "se";
        if (act.equals(WorldModel.Move.west.toString()))        return "w ";
        if (act.equals(WorldModel.Move.northwest.toString()))   return "nw";
        if (act.equals(WorldModel.Move.southwest.toString()))   return "sw";
        if (act.equals(WorldModel.Move.north.toString()))       return "n ";
        if (act.equals(WorldModel.Move.south.toString()))       return "s ";
        if (act.equals(WorldModel.Move.skip.toString()))        return "--";
        return act;
    }
    
    synchronized private void waitNextCycle() throws InterruptedException {
        wait(10000);
    }
    
    synchronized void go() {
        notifyAll();
    }

}
