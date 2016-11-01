package graphLib;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

public class BestCoverageFewEdges implements BestCoverageInterface {
    private int queue[] = new int[Graph.MAXVERTICES];
    private boolean white[] = new boolean[Graph.MAXVERTICES];
    private int depth[] = new int[Graph.MAXVERTICES];
    
    public ArrayList<Integer> execute(Graph g, int k) {
        ArrayList<Integer> list = new ArrayList<Integer>();
        
        int best = Graph.NULL;
        int vBest = Graph.NULL;
        int fbegin;
        int fend;
        int u;
        int currentValue;
        
        for (int i = 0; i <= g.getSize(); i++) {
            
            for (int j = 0; j <= g.getSize(); j++) {
                white[j] = true;
            }
            
            fbegin = 0;
            fend = 0;
            currentValue = 0;
            
            queue[fend++] = i;
            depth[i] = 0;
            white[i] = false;
            
            u = i;
            for (int j = 0; j < g.grade[u]; j++) {
                int v = g.adj[u][j];
                if (white[v] && g.values[u] == g.values[v]) {
                    white[v] = false;
                    depth[v] = 0;
                    queue[fend++] = v;
                }
            }
            
            while (fbegin < fend) {
                u = queue[fbegin++];
                
                if (fbegin <= k) {
                    if (g.values[u] == Graph.NULL) 
                        currentValue++;
                    else
                        currentValue+=g.values[u];
                } else {
                    break;
                }
                
                for (int j = 0; j < g.grade[u]; j++) {
                    int v = g.adj[u][j];
                    if (white[v]) {
                        white[v] = false;
                        depth[v] = depth[u]+1;
                        queue[fend++] = v;
                    }
                }
            }
            
            if (currentValue > vBest || (currentValue == vBest && g.values[i] > g.values[best])) {
                vBest = currentValue;
                best = i;
            }
        }
        
        
        if (best != Graph.NULL) {
            list.add(0, best);
            list.add(1, vBest);
        }
        return list;
    }
    
    
    public ArrayList<Integer> execute(Graph g, int k, int vertexIgnore) {
        ArrayList<Integer> list = new ArrayList<Integer>();
        Set<Integer> neighborhoodIgnore =  new HashSet<Integer>();
        
        int best = Graph.NULL;
        int vBest = Graph.NULL;
        int fbegin;
        int fend;
        int u;
        int currentValue;
        
        neighborhoodIgnore.add(vertexIgnore);
        u = vertexIgnore;
        for (int j = 0; j < g.grade[u]; j++) {
            int v = g.adj[u][j];
            neighborhoodIgnore.add(v);
        }
        
        for (int i = 0; i <= g.getSize(); i++) {
            
            if (neighborhoodIgnore.contains(i)) {
                continue;
            }
            
            for (int j = 0; j <= g.getSize(); j++) {
                white[j] = true;
            }
            
            fbegin = 0;
            fend = 0;
            currentValue = 0;
            
            queue[fend++] = i;
            depth[i] = 0;
            white[i] = false;
            
            u = i;
            for (int j = 0; j < g.grade[u]; j++) {
                int v = g.adj[u][j];
                if (white[v] && g.values[u] == g.values[v]) {
                    white[v] = false;
                    depth[v] = 0;
                    queue[fend++] = v;
                }
            }
            
            while (fbegin < fend) {
                u = queue[fbegin++];
                
                if (fbegin <= k) {
                    if (g.values[u] == Graph.NULL) 
                        currentValue++;
                    else
                        currentValue+=g.values[u];
                } else {
                    break;
                }
                
                for (int j = 0; j < g.grade[u]; j++) {
                    int v = g.adj[u][j];
                    if (white[v]) {
                        white[v] = false;
                        depth[v] = depth[u]+1;
                        queue[fend++] = v;
                    }
                }
            }
            
            if (currentValue > vBest || (currentValue == vBest && g.values[i] > g.values[best])) {
                vBest = currentValue;
                best = i;
            }
        }
        
        
        if (best != Graph.NULL) {
            list.add(0, best);
            list.add(1, vBest);
        }
        return list;
    }
}
