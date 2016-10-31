package results.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.Map;
import java.util.TreeMap;

/** get several executions and merge them into a file */
public class MergeResultsPartners {

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("The directory where the experiment results are placed should be informed.");
            System.err.println("The name of target team should be informed.");
        } else {
            new MergeResultsPartners().run(new File(args[0]), args[1]);
        }
    }


    // team name -> <step -> opinions>
    Map<String,Map<Integer, Integer>> opReq = new TreeMap<String,Map<Integer,Integer>>();
    int maxstep = 0;
    int nbruns  = 0;
    
    public void run(File dir, String team) throws Exception {
        load(dir, team);
        store(dir);
        createGnuPlotScript(dir);
    }
    
    void load(File dir, String team) throws Exception {
        // for all execution
        for (File f: dir.listFiles()) {
            File fin = new File(f+"/"+Constants.commFile);
            if (fin.exists()) {
                nbruns++;
                System.out.println("Loading data from "+fin);
                BufferedReader in = new BufferedReader(new FileReader(fin));
                String line = null;
                while ( (line = in.readLine()) != null) {
                    CommLine com = new CommLine(line);
                    if (com.sender.equals(team) && com.type.equals(Constants.opReqMsg)) {
                        // get partner data
                        Map<Integer,Integer> p = opReq.get(com.receiver);
                        if (p == null) {
                            p = new TreeMap<Integer,Integer>();
                            opReq.put(com.receiver, p);
                        }
                        // get step data
                        Integer n = p.get(com.step);
                        if (n == null) {
                            p.put(com.step, 1);
                        } else {
                            p.put(com.step, n.intValue()+1);
                        }
                        
                        if (com.step > maxstep)
                            maxstep = com.step;
                    }
                }
            }
        }
    }

    void store(File dir) throws Exception {
        File agdir = new File(dir+"/agents-partners");
        if (!agdir.exists()) {
            agdir.mkdirs();
        }
        
        for (String team: opReq.keySet()) {
            File teamout = new File(agdir+"/"+team);
            PrintWriter out = new PrintWriter(new FileWriter(teamout));
            
            Map<Integer,Integer> p = opReq.get(team);
            
            for (int step = 0; step <= maxstep; step++) {
                Integer v = p.get(step);
                if (v == null)
                    v = 0;
                out.println(step+","+ (v/nbruns));
            }
            
            out.close();
        }
    }
    
    void createGnuPlotScript(File dir) throws Exception {
        System.out.println("Creating script gnuplot: "+Constants.gnuplotPartnersScript);
        PrintWriter out = new PrintWriter(dir+"/"+Constants.gnuplotPartnersScript);
        out.println("#!/usr/bin/gnuplot -persist");
        out.println("set datafile separator \",\"");
        out.println("#set title \"Simulation Result\"");
        out.println("set xlabel \"step\"");
        out.println("set ylabel \"requested opinions\"");
        out.println("#set xrange [0:19]");
        out.println("set yrange [-1:25]");
        out.println("set key top left");
        out.println("set terminal postscript eps enhanced color 18");
        out.println("set output \""+dir+"/partners.eps\"");
        
        String plot = "plot ";
        for (String team: opReq.keySet()) {
            out.print(plot+"\""+dir+"/agents-partners/"+team+"\" title \""+team+"\" smooth bezier with linespoints");
            plot = ",\\\n     ";
        }
        out.println();

        out.close();
    }
}
