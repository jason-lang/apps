package graphLib;

import java.util.LinkedList;
import java.util.List;

public class NeighborhoodFewEdges implements NeighborhoodInterface {
    private int queue[] = new int[Graph.MAXVERTICES];
    private boolean white[] = new boolean[Graph.MAXVERTICES];
    private int depth[] = new int[Graph.MAXVERTICES];
    
    public List<Integer> execute(Graph g, int s, int k) {
        List<Integer> list = new LinkedList<Integer>();
        
        int fbegin;
        int fend;
        int u;
        
        for (int j = 0; j <= g.getSize(); j++) {
            white[j] = true;
        }
        
        fbegin = 0;
        fend = 0;
        
        queue[fend++] = s;
        depth[s] = 0;
        white[s] = false;
        list.add(s);
        
        
        u = s;
        for (int j = 0; j < g.grade[u]; j++) {
            int v = g.adj[u][j];
            if (white[v] && g.values[u] == g.values[v]) {
                white[v] = false;
                depth[v] = 0;
                queue[fend++] = v;
                list.add(v);
            }
        }
        
        int average = g.getAverageVertex();
        if (average >= 6)
            average = 5;
        int aveTwo = (int) (average + 0.9 * average + 0.4);
        int aveOne = (int) (average + 2);
        int v;
        int j;
        
        while (fbegin < fend) {
            u = queue[fbegin++];
            
            if (fbegin > k + 2) { //After 6 vertices maybe it doesn't matter anymore
                break;
            } else if (fbegin > k + 1) { //It must be an important vertice to add
                if (g.values[u] >= aveOne)
                    list.add(u);
            } else if (fbegin > k) { //Maybe I can add more vertices
                if (g.values[u] >= aveOne)
                    list.add(u);
                
                for (j = 0; j < g.grade[u]; j++) {
                    v = g.adj[u][j];
                    if (white[v] && g.values[v] >= aveOne) {
                        white[v] = false;
                        depth[v] = depth[u]+1;
                        queue[fend++] = v;
                    }
                }
            } else {
                list.add(u);
                
                for (j = 0; j < g.grade[u]; j++) {
                    v = g.adj[u][j];
                    if (white[v]) {
                        white[v] = false;
                        depth[v] = depth[u]+1;
                        queue[fend++] = v;
                    }
                }
            }
        }
            
        return list;
    }
}
