package graphLib;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

public class PivotAlgorithm {
    private List<PairPivot> pairs = new ArrayList<PairPivot>();
    private boolean map[][] = new boolean[Graph.MAXVERTICES][Graph.MAXVERTICES]; //inicialized with false
    private long primes[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47}; //Used to create id, without clash. It must have around 6 vertex at most, otherwise it can get overflow.
    //private long primes[] = {32869, 467, 271787, 1471, 32869, 9749, 150559, 25121, 662369, 66529, 631, 516349, 71257, 547, 125201, 2239}; //Used to create an id, it is rare to clash with different numbers.
    private Set<Long> ids = new HashSet<Long>();
    
    private boolean ignoreVertex[] = new boolean[Graph.MAXVERTICES]; //inicialized with false
    private boolean justUseVertex[] = new boolean[Graph.MAXVERTICES]; //inicialized with false
    private boolean justUseSomeVertices = false;
    
    public void setVerticesToIgnore(List<Integer> listVerticesIgnore) {
        for (int v : listVerticesIgnore) {
            ignoreVertex[v] = true;
        }
    }
    
    public void setVerticesToJustUse(List<Integer> listVerticesToUse) {
        justUseSomeVertices = true;
        for (int v : listVerticesToUse) {
            justUseVertex[v] = true;
        }
    }
    
    public List<PairPivot> execute(Graph g, int amount) {
        
        int u, v, i, j, w, k, x;
        int value;
        long id;
        int p;
        
        //for each possible vertex pivot u
        for (u = 0; u <= g.getSize(); u++) {
            if (ignoreVertex[u]) continue; //Ignore this vertice
            if (justUseSomeVertices && !justUseVertex[u]) continue; //If I just can use some vertices I need to ignore this one

            //using v as intermediary vertex
            for (i = 0; i < g.grade[u]; i++) {
                v = g.adj[u][i];
                if (ignoreVertex[v]) continue; //Ignore this vertice
                
                //and w as possible vertex aux
                for (j = 0; j < g.grade[v]; j++) {
                    w = g.adj[v][j];
                    if (ignoreVertex[w]) continue; //Ignore this vertice
                    if (justUseSomeVertices && !justUseVertex[w]) continue; //If I just can use some vertices I need to ignore this one
                    
                    if (u == w || map[u][w] || map[w][u]) continue;
                    map[u][w] = true;
                    
                    //Create new pairPivot
                    PairPivot newPivot = new PairPivot(u, w);
                    newPivot.addVertex(u);
                    newPivot.addVertex(w);
                    
                    //check all vertices x between w and u and put in the list
                    value = 0;
                    id = 1;
                    p = 0;
                    for (k = 0; k < g.grade[u]; k++) {
                        x = g.adj[u][k];
                        if (ignoreVertex[x]) continue; //Ignore this vertice
                        
                        //there is a link between u~x~w
                        if (g.w[x][w] != Graph.INF) {
                            if (g.values[x] == Graph.NULL)
                                value++;
                            else
                                value += g.values[x];
                            id *= primes[p++] * x;
                            newPivot.addVertex(x);
                        }
                    }
                    if (g.values[u] == Graph.NULL)
                        value++;
                    else
                        value += g.values[u];
                    id *= primes[p++] * u;
                    if (g.values[w] == Graph.NULL)
                        value++;
                    else
                        value += g.values[w];
                    id *= primes[p++] * w;
                    if (!ids.contains(id)) { //Avoid the same group of vertices
                        newPivot.setValue(value);
                        pairs.add(newPivot);
                        ids.add(id);
                    }
                }
            }
        }
        
        addConnectedVertices(g);
        addIslands(g);
        
        Collections.sort(pairs);
        List<PairPivot> pairsResult = new ArrayList<PairPivot>();
        
        for (PairPivot pair : pairs) {
            if (amount == 0) break;
            
            if (!validPivot(pair)) 
                continue;
            
            amount--;
            pairsResult.add(pair);
            
            for (int z : pair.getVertices()) {
                ignoreVertex[z] = true;
            }
        }
        
        return pairsResult;
    }
    
    private void addIslands(Graph g) {
        GlobalGraph globalGraph = GlobalGraph.getInstance();
        List<Integer> listAdd = new LinkedList<Integer>();
        for (PairPivot pair : pairs) { //for each pair pivot
            listAdd.clear();
            for (int v : pair.getVertices()) { //for each v of that pair pivot 
                Island islandV = globalGraph.getIsland(v); 
                if (islandV != null) { //check if v is an island
                    for (int w : islandV.getVertices()) { //for each w of that island
                        if (!pair.contains(w)) { //except v
                            listAdd.add(w);
                        }
                    }
                }
            }
            
            int value = pair.getValue(); //get the old value
            for (int w : listAdd) {
                pair.addVertex(w); //add the new vertices and sum the value
                if (g.values[w] == Graph.NULL)
                    value++;
                else
                    value += g.values[w];
            }
            pair.setValue(value); //update the new value
        }
    }
    
    private void addConnectedVertices(Graph g) {
        int queue[] = new int[Graph.MAXVERTICES];
        for (PairPivot pair : pairs) {
            int fbegin = 0;
            int fend = 0;
            for (int v : pair.getVertices()) { //for each v of that pair pivot
                queue[fend++] = v;
            }
            
            while (fbegin < fend) { 
                int u = queue[fbegin++];
                
                for (int i = 0; i < g.grade[u]; i++) { //Test all adjacent v vertices
                    int v = g.adj[u][i];
                    
                    if (!pair.contains(v) && evaluateConnectedVertice(g, pair, v)) { //if v doesn't belong to the pivot, test if it is just connected to vertices that belongs to the pivot
                        
                        int value = pair.getValue(); //get the old value
                        pair.addVertex(v); //add the new vertices and sum the value
                        if (g.values[v] == Graph.NULL)
                            value++;
                        else
                            value += g.values[v];
                        pair.setValue(value); //update the new value
                        
                        //queue[fend++] = v; //add if it is necessary more rounds to get more vertices (TODO disabled by default because of performance)
                    }
                }
            }
        }
    }
    
    private boolean evaluateConnectedVertice(Graph g, PairPivot pair, int u) {
        for (int i = 0; i < g.grade[u]; i++) { //Test all adjacent v vertices
            int v = g.adj[u][i];
            if (!pair.contains(v)) {
                return false;
            }
        }
        return true;
    }
    
    private boolean validPivot(PairPivot pair) {
        for (int v : pair.getVertices()) {
            if (ignoreVertex[v]) return false;
        }
        return true;
    }
}
