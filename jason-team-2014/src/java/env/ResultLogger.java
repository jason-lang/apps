package env;

import graphLib.Graph;

import java.io.FileWriter;
import java.io.IOException;

public class ResultLogger {
    private String fileName = "result.txt";
    private long seed = 0;
    private int edges = 0;
    private int vertices = 0;
    private int score = 0;
    private int ranking = 0;
    private int valueVertices[] = new int[11];
    private Graph g = null;

    public ResultLogger() {
    }
    
    public void reset() {
        edges = 0;
        vertices = 0;
        score = 0;
        ranking = 0;
        for (int i = 0; i<= Graph.MAXVERTEXVALUE; i++) {
            valueVertices[i] = 0;
        }
    }
    
    public void setGraph(Graph g) {
        this.g = g;
    }
    
    public void setSeed(long seed) {
        this.seed = seed;
    }
    
    public void setScore(int score) {
        this.score = score;
    }
    
    public void setRanking(int ranking) {
        this.ranking = ranking;
    }
    
    public void addValues() {
        this.edges = g.getEdges();
        this.vertices = g.getSize();
        for (int v = 0; v <= g.getSize(); v++) {
            if (g.values[v] != Graph.NULL) {
                valueVertices[g.values[v]]++;
            }
        }
    }
    
    public void commitLine() {
        StringBuffer line = new StringBuffer();
        line.append(seed+","+vertices+","+edges+","+ranking+","+score);
        for (int i = 1; i <= Graph.MAXVERTEXVALUE; i++) {
            line.append(","+valueVertices[i]);
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
