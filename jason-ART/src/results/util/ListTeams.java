package results.util;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.Set;
import java.util.TreeSet;

/** list all teams of the experiment */
public class ListTeams {
    
    public static Set<String> teams(String file) throws Exception {
        Set<String> teams = new TreeSet<String>();
        BufferedReader in = new BufferedReader(new FileReader(file));
        String line = null;
        while ( (line = in.readLine()) != null) {
            AgentLine ag = new AgentLine(line);
            if (teams.contains(ag.team))
                break;
            teams.add(ag.team);
        }
        return teams;        
    }
    
    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.err.println("The directory where the execution result is placed should be informed.");
        } else {
            for (String t : teams(args[0]+"/"+Constants.agentsFile)) {
                System.out.println(t);
            }
        }
    }

}
