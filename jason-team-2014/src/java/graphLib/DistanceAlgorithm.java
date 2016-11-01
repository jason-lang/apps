package graphLib;

public class DistanceAlgorithm {
    private int dist[] = new int[Graph.MAXVERTICES];
    private int queue[] = new int[Graph.MAXVERTICES];
    
    public int execute(Graph g, int s, int d) {
        for (int i = 0; i <= g.getSize(); i++) {
            dist[i] = Graph.INF;
        }
        
        dist[s] = 0;
        
        int fbegin = 0;
        int fend = 0;
        int u;
        int v;
        int i;
        
        queue[fend++] = s;
        
        boolean found = false;
        while (fbegin < fend && !found) {
            u = queue[fbegin++];
            
            for (i = 0; i < g.grade[u]; i++) {
                v = g.adj[u][i];
                
                if (dist[v] == Graph.INF) {
                    dist[v] = dist[u] + 1;
                    if (v == d) {
                        found = true;
                        break;
                    }
                    queue[fend++] = v;
                }
            }
        }
        
        return dist[d];
    }
}
