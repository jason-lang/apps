package graphLib;

import java.util.LinkedList;
import java.util.List;
import java.util.PriorityQueue;

public class DijkstraAlgorithm {
    private int pred[] = new int[Graph.MAXVERTICES];
    private int dist[] = new int[Graph.MAXVERTICES];
    
    public List<Integer> execute(Graph g, int s, int d) {
        List<Integer> path = null;
        PriorityQueue<PairPriority> queue = new PriorityQueue<PairPriority>();
        
        for (int i = 0; i <= g.getSize(); i++) {
            pred[i] = Graph.NULL;
            dist[i] = Graph.INF;
        }
        
        dist[s] = 0;
        pred[s] = Graph.NULL;
        
        queue.offer(new PairPriority(s, 0));
        
        while (!queue.isEmpty()) {
            PairPriority pair = queue.poll();
            int u = pair.getkey();
            
            if (u == d) break;
            
            for (int i = 0; i < g.grade[u]; i++) {
                int v = g.adj[u][i];
                
                if (dist[v] > dist[u] + g.w[u][v]) {
                    queue.remove(new PairPriority(v, dist[v]));
                    dist[v] = dist[u] + g.w[u][v];
                    pred[v] = u;
                    queue.offer(new PairPriority(v, dist[v]));
                }
            }
        }
        
        if (dist[d] != Graph.INF) {
            path = new LinkedList<Integer>();
            path.add(d);
            for (int v = pred[d]; v != Graph.NULL; v = pred[v]) {
                path.add(v);
            }
        }
        return path;
    }
}
