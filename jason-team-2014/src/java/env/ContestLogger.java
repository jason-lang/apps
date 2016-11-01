package env;

import java.io.FileWriter;
import java.io.IOException;

public class ContestLogger {
    private static ContestLogger contestLogger = new ContestLogger();
    private int currentStep = 0;
    private String action[] = new String[29];
    private String actionResult[] = new String[29];
    private String team = null;
    private String fileName = null;
 
    private ContestLogger() {
        for (int i = 0; i < 29; i++) {
            action[i] = "*";
            actionResult[i] = "*";
        }
    }
    
    public static ContestLogger getInstance() {
        return contestLogger;
    }
    
    public synchronized void reset() {
        if (currentStep > 0) {
            currentStep = 0;
            for (int i = 0; i < 29; i++) {
                action[i] = "*";
                actionResult[i] = "*";
            }
        }
    }
    
    public synchronized void addAction(String team, int agentId, 
                                        int step, String action, String result) {
        if (this.team == null) {
            this.team = team;
            this.fileName = team + ".log"; 
            writeHead();
        }
        
        if (step > currentStep) {
            commitLine();
            for (int i = 0; i < 29; i++) {
                this.action[i] = "*";
                actionResult[i] = "*";
            }
            currentStep = step;
        }
        this.action[agentId] = action.substring(0, 1);
        this.actionResult[agentId] = result.substring(0,1);
    }
    
    private void writeHead() {
        FileWriter fw;
        try {
            fw = new FileWriter(fileName, false);
            fw.write("");
            fw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    private void commitLine() {
        StringBuffer line = new StringBuffer();
        line.append(""+currentStep);
        for (int i = 1; i < 29; i++) {
            line.append(" " + action[i] + "/" + actionResult[i]);
        }
        line.append("\n");
        
        FileWriter fw;
        try {
            fw = new FileWriter(fileName, true);
            fw.write(line.toString());
            fw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
