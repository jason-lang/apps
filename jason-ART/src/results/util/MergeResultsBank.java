package results.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/** get several executions and merge them into a file */
public class MergeResultsBank {

    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.err.println("The directory where the experiment results are placed should be informed.");
        } else {
            new MergeResultsBank().run(new File(args[0]));
        }
    }


    // team name -> <step -> list of bank values>
    Map<String,Map<Integer,List<Double>>> teams = new TreeMap<String,Map<Integer,List<Double>>>();
    
    public void run(File dir) throws Exception {
        load(dir);
        store(dir);
        createGnuPlotScript(dir);
    }
    
    void load(File dir) throws Exception {
        // for all execution
        for (File f: dir.listFiles()) {
            File fin = new File(f+"/"+Constants.agentsFile);
            if (fin.exists()) {
                System.out.println("Loading data from "+fin);
                BufferedReader in = new BufferedReader(new FileReader(fin));
                String line = null;
                while ( (line = in.readLine()) != null) {
                    AgentLine ag = new AgentLine(line);
                    // get team data
                    Map<Integer,List<Double>> team = teams.get(ag.team);
                    if (team == null) {
                        team = new TreeMap<Integer,List<Double>>();
                        teams.put(ag.team, team);
                    }
    
                    //get step data
                    List<Double> step = team.get(ag.step);
                    if (step == null) {
                        step = new ArrayList<Double>();
                        team.put(ag.step, step);
                    }
                    
                    step.add(ag.bank);
                }
            }
        }
    }

    void store(File dir) throws Exception {
        //System.out.println(teams);
        File agdir = new File(dir+"/agents-bank");
        if (!agdir.exists()) {
            agdir.mkdirs();
        }
        
        for (String team: teams.keySet()) {
            File teamout = new File(agdir+"/"+team);
            PrintWriter out = new PrintWriter(new FileWriter(teamout));
            
            for (int step: teams.get(team).keySet()) {
                out.print(step);
                
                double sum = 0;
                int    c = 0;
                double max=Double.MIN_VALUE, min=Double.MAX_VALUE;
                for (double d: teams.get(team).get(step)) {
                    sum += d;
                    c++;
                    if (d>max) max = d;
                    if (d<min) min = d;
                }
                out.println(","+ (sum/c) + "," + max  + "," + min );
            }
            
            out.close();
        }
    }
    
    void createGnuPlotScript(File dir) throws Exception {
        System.out.println("Creating script gnuplot: "+Constants.gnuplotBankScript);
        PrintWriter out = new PrintWriter(dir+"/"+Constants.gnuplotBankScript);
        out.println("#!/usr/bin/gnuplot -persist");
        out.println("set datafile separator \",\"");
        out.println("#set title \"Simulation Result\"");
        out.println("set xlabel \"step\"");
        out.println("#set xrange [0:19]");
        out.println("set ylabel \"money\"");
        out.println("set key top left");
        out.println("set terminal postscript eps enhanced color 18");
        out.println("set output \""+dir+"/bank-a.eps\"");
        
        String plot = "plot ";
        for (String team: teams.keySet()) {
            //out.println(plot+"\"experiment1/agents-bank/"+team+"\" title \""+team+"\" with yerrorbars, \"\" smooth csplines notitle \\");
            out.print(plot+"\""+dir+"/agents-bank/"+team+"\" title \""+team+"\" lc \"black\" with linespoints");
            plot = ",\\\n     ";
        }
        out.println();

        out.println("\nset output \""+dir+"/bank-b.eps\"");
        plot = "plot ";
        for (String team: teams.keySet()) {
            out.print(plot+"\""+dir+"/agents-bank/"+team+"\" title \""+team+"\" with yerrorbars, \"\" smooth csplines notitle");
            plot = ",\\\n     ";
        }
        out.println();
        
        out.close();
    }
}
