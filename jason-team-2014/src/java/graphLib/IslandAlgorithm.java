package graphLib;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class IslandAlgorithm {
    private Graph g;
    
    public static final int WHITE = 0;
    public static final int GRAY = 1;
    public static final int BLACK = 2;
    
    private int low[] = new int[Graph.MAXVERTICES];
    private int num[] = new int[Graph.MAXVERTICES];
    private int pred[] = new int[Graph.MAXVERTICES]; 
    private int childs[] = new int[Graph.MAXVERTICES]; //Initialized with 0 by JVM
    private int color[] = new int[Graph.MAXVERTICES]; //Initialized with 0 by JVM (WHITE)
    private int art[] = new int[Graph.MAXVERTICES]; //Initialized with 0 by JVM.
    private int brokenBridge[][] = new int[Graph.MAXVERTICES][Graph.MAXVERTICES]; //It can be broken 0, 1 or 2. 0 means no broken. 1 means broken because all cut vertices were disconnected. 2 means broken because just the cut vertices connected to the big island were marked.
    
    
    private boolean belongsBigIsland[] = new boolean[Graph.MAXVERTICES]; 
    private int queue[] = new int[Graph.MAXVERTICES];
    private Island biggestIslandArt[] = new Island[Graph.MAXVERTICES]; //It has the biggest island for each cut vertex
    
    private List<Island> islands = new ArrayList<Island>();
    
    public List<Island> execute(Graph g, int amount) {
        this.g = g;
        
        findCutVertices();
        findIslands();
        
        Collections.sort(islands);
        List<Island> islandsResult = new ArrayList<Island>();
        
        for (Island island : islands) {
            if (amount == 0) break;
            
            amount--;
            islandsResult.add(island);
        }
        
        /*
        for (Island currentIsland : islands) {
            System.out.print("Island id: " + currentIsland.getCutVertex() + " sum: " + currentIsland.getValue() + " vertices: " );
            for (int i : currentIsland.getVertices()) {
                System.out.print(i + " ");
            }
            System.out.println();
        }*/
        
        return islandsResult;
    }
    
    /*
     * 
     * For each cut vertex, disconnect it and find all formed islands
     * Define which is the biggest island and which are the little islands
     */
    private void findIslands() {
        for (int v = 0; v <= g.getSize(); v++) {
            if (art[v] > 0) {
                disconnectEdges(v);
                
                bfs(v);
                
                //Break the bridges to the new island
                breakBridgesToBiggestIsland(v);
                
                //Find which are the vertices of the island v
                buildIsland(v);
                
                connectEdges(v);
            }
        }
        
        //Delete repeated islands
        filterIslands();
        
        //Add islands to the global graph
        addIslandsToGlobalGraph();
    }
    
    /*
     * Add all islands to the global Graph
     */
    private void addIslandsToGlobalGraph() {
        GlobalGraph graph = GlobalGraph.getInstance();
        
        for (int v = 0; v <= g.getSize(); v++) {
            if (art[v] > 0) {
                graph.setIsland(v, biggestIslandArt[v]);
            } else {
                graph.setIsland(v, null);
            }
        }       
    }
    
    /*
     * Filter which are the real islands
     */
    private void filterIslands() {
        List<Island> islandsNew = new ArrayList<Island>();
        
        
        for (Island island : islands) {
            for (int v : island.getVertices()) {
                if (art[v] > 0) {
                    if (biggestIslandArt[v] == null) {
                        System.out.println("Something wrong with vertex cut " + v);
                        biggestIslandArt[v] = island;
                    }
                    
                    if (island.getValue() > biggestIslandArt[v].getValue()) {
                        biggestIslandArt[v] = island;
                    }
                }
            }
        }
        
        for (int v = 0; v <= g.getSize(); v++) {
            if (art[v] > 0 && art[biggestIslandArt[v].getCutVertex()] <= 1) {
                islandsNew.add(biggestIslandArt[v]);
                art[biggestIslandArt[v].getCutVertex()] = 2;
            }
        }
        
        islands = islandsNew;
    }
    
    /*
     * Search an initial vertex to start the cut algorithm
     */
    private void findCutVertices() {
        
        for (int i = 0; i <= g.getSize(); i++) {
            pred[i] = i;
            color[i] = WHITE;
        } 

        int s;
        for(s = 0; !g.known[s]; s++);
        
        dfs(s, 1);
    }
    
    /*
     * Find all cut vertices
     */
    private void dfs(int v, int niv) {
        color[v] = GRAY;
        low[v] = niv;
        num[v] = niv;

        int i, w;
        for (i = 0; i < g.grade[v]; i++) {
            
            w = g.adj[v][i];
            
            if (color[w] == WHITE) {
                pred[w] = v;
                dfs(w, niv + 1);
                if (niv > 1 && low[w] >= num[v]) {
                    art[v] = 1; //found v
                }
                if (low[w] < low[v])
                    low[v] = low[w];

                childs[v]++;
            } else if (color[w] == GRAY) {
                if (num[w] < low[v])
                    low[v] = num[w];
            }
        }

        if (niv == 1 && childs[v] > 1) {
            art[v] = 1; //found v
        }

        color[v] = BLACK;
    }
    
    /*
     * Disconnect all edges of vertex v
     */
    private void disconnectEdges(int v) {
        for (int i = 0; i < g.grade[v]; i++) {
            int w = g.adj[v][i];

            brokenBridge[v][w] = brokenBridge[w][v] = 1;
        }
    }

    /*
     * Connect all edges of vertex v
     */
    private void connectEdges(int v) {
        for (int i = 0; i < g.grade[v]; i++) {
            int w = g.adj[v][i];

            brokenBridge[v][w] = brokenBridge[w][v] = 0;
        }
    }
    
    /*
     * Disconnect again the edges of vertex u that link with the big island
     */
    private void breakBridgesToBiggestIsland(int u) {
        
        for (int i = 0; i < g.grade[u]; i++) {
            int v = g.adj[u][i];
            
            if (belongsBigIsland[v]) {
                brokenBridge[u][v] = brokenBridge[v][u] = 2;
            }
        }
    }
    
    private void bfs(int x) {
        List<Integer> verticesIsland[] = new LinkedList[Graph.MAXVERTICES];
        
        //BFS to find the islands of vertex x when it is disconnected
        int s;
        for (s = 0; s <= g.getSize(); s++) {
            belongsBigIsland[s] = false;
            color[s] = WHITE;
            verticesIsland[s] = new LinkedList<Integer>();
        }

        for (s = 0; s <= g.getSize(); s++) {
            if (color[s] == WHITE && g.known[s]) {
                
                int fbegin = 0;
                int fend = 0;
                int u;
                int v;
                int i;
                
                queue[fend++] = s;
                
                verticesIsland[s].add(s);
                color[s] = BLACK;
                
                while (fbegin < fend) {
                    u = queue[fbegin++];
                    
                    for (i = 0; i < g.grade[u]; i++) {
                        v = g.adj[u][i];
                        
                        if (brokenBridge[u][v] == 0 && color[v] == WHITE) {
                            queue[fend++] = v;
                            color[v] = BLACK;
                            
                            verticesIsland[s].add(v);
                        }
                    }
                }
            }
        }
        
        //Figure out the biggest island
        int biggestIsland = -1;
        int biggestVertex = -1;
        for (s = 0; s <= g.getSize(); s++) {
            if (verticesIsland[s].size() > biggestIsland) {
                biggestIsland = verticesIsland[s].size();
                biggestVertex = s;
            }
        }
        
        //Mark all vertices that belong to the biggest island
        belongsBigIsland[biggestVertex] = true;
        for (int v : verticesIsland[biggestVertex]) {
            belongsBigIsland[v] = true;
        }
    }
    
    /*
     * Build the island for vertex x
     */
    private void buildIsland(int x) {
        Island newIsland = new Island(x);
        
        int fbegin = 0;
        int fend = 0;
        int u;
        int v;
        int i;
        int value = 0;
        
        for (i = 0; i <= g.getSize(); i++) {
            color[i] = WHITE;
        }
                
        queue[fend++] = x;
        
        newIsland.addVertex(x);
        
        if (g.values[x] == Graph.NULL)
            value++;
        else
            value += g.values[x];   
        
        
        color[x] = BLACK;
        
        while (fbegin < fend) {
            u = queue[fbegin++];
            
            for (i = 0; i < g.grade[u]; i++) {
                v = g.adj[u][i];
                
                if (brokenBridge[u][v] <= 1 && color[v] == WHITE) {
                    queue[fend++] = v;
                    color[v] = BLACK;
                    
                    newIsland.addVertex(v);
                    
                    if (g.values[v] == Graph.NULL)
                        value++;
                    else
                        value += g.values[v];                   
                    
                }
            }
        }

        newIsland.setValue(value);
        islands.add(newIsland);
        
        biggestIslandArt[x] = newIsland;
    }
}
