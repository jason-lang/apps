package results.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.Map;
import java.util.TreeMap;

/** get several executions and merge them into a file */
public class CreateTimeUsed {

    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.err.println("The directory where the experiment results are placed should be informed.");
        } else {
            new CreateTimeUsed().run(new File(args[0]));
        }
    }


    // team name -> <step -> time>
    Map<String,Map<Integer,Long>> teams = new TreeMap<String,Map<Integer,Long>>();
    
    public void run(File dir) throws Exception {
        load(dir);
        store(dir);
        createGnuPlotScript(dir);
    }
    
    void load(File dir) throws Exception {
        File fin = new File(dir+"/"+Constants.timesFile);
        if (fin.exists()) {
            System.out.println("Loading data from "+fin);
            BufferedReader in = new BufferedReader(new FileReader(fin));
            String line = null;
            while ( (line = in.readLine()) != null) {
                TimeLine time = new TimeLine(line);
                
                // get team data
                Map<Integer,Long> team = teams.get(time.team);
                if (team == null) {
                    team = new TreeMap<Integer,Long>();
                    teams.put(time.team, team);
                }
                
                long current = 0;
                if (team.containsKey(time.step))
                    current = team.get(time.step);
                team.put(time.step, (current+time.time));
            }
        }
    }

    void store(File dir) throws Exception {
        //System.out.println(teams);
        File timedir = new File(dir+"/times");
        if (!timedir.exists()) {
            timedir.mkdirs();
        }
        
        for (String team: teams.keySet()) {
            File teamout = new File(timedir+"/"+team);
            PrintWriter out = new PrintWriter(new FileWriter(teamout));
            for (int step: teams.get(team).keySet()) {
                long elapt = teams.get(team).get(step);
                out.println(step+","+elapt);
            }
            
            out.close();
        }
    }
    
    void createGnuPlotScript(File dir) throws Exception {
        System.out.println("Creating script gnuplot: "+Constants.gnuplotTimesScript);
        PrintWriter out = new PrintWriter(dir+"/"+Constants.gnuplotTimesScript);
        out.println("#!/usr/bin/gnuplot -persist");
        out.println("set datafile separator \",\"");
        out.println("set xlabel \"step\"");
        out.println("set xrange [20:49]");
        out.println("set ylabel \"time consumed\"");
        out.println("set key top left");
        out.println("set terminal postscript eps enhanced color 18");
        out.println("set output \""+dir+"/time.eps\"");
        
        String plot = "plot ";
        for (String team: teams.keySet()) {
            //out.println(plot+"\"experiment1/agents-bank/"+team+"\" title \""+team+"\" with yerrorbars, \"\" smooth csplines notitle \\");
            out.print(plot+"\""+dir+"/times/"+team+"\" title \""+team+"\" lc \"black\" smooth bezier with linespoints");
            plot = ",\\\n     ";
        }
        out.println();

        out.close();
    }
}
