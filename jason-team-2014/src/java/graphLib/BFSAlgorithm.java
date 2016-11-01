package graphLib;

import java.util.LinkedList;
import java.util.List;

public class BFSAlgorithm {
    private int pred[] = new int[Graph.MAXVERTICES];
    private int dist[] = new int[Graph.MAXVERTICES];
    private int queue[] = new int[Graph.MAXVERTICES];
    
    public List<Integer> execute(Graph g, int s, List<Integer> ds) {
        List<Integer> path = null;
        
        for (int i = 0; i <= g.getSize(); i++) {
            pred[i] = Graph.NULL;
            dist[i] = Graph.INF;
        }
        
        dist[s] = 0;
        pred[s] = Graph.NULL;
        
        int fbegin = 0;
        int fend = 0;
        int u;
        int v;
        int i;
        
        queue[fend++] = s;
        
        while (fbegin < fend) {
            u = queue[fbegin++];
            
            for (i = 0; i < g.grade[u]; i++) {
                v = g.adj[u][i];
                
                if (dist[v] == Graph.INF) {
                    dist[v] = dist[u] + 1;
                    pred[v] = u;
                    queue[fend++] = v;
                }
            }
        }
        
        int d = Graph.NULL;
        int min = Graph.INF;
        for (int y : ds) {
            if (dist[y] < min) {
                d = y;
                min = dist[y];
            }
        }
        
        if (d != Graph.NULL && dist[d] != Graph.INF) {
            path = new LinkedList<Integer>();
            path.add(d);
            for (int y = pred[d]; y != Graph.NULL; y = pred[y]) {
                path.add(y);
            }
        }
        return path;
    }
}
