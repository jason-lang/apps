package graphLib;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class Graph {
    public static final int INF = 10000;
    public static final int MAXWEIGHT = 10;
    public static final int NULL = -1;
    public static final int MAXVERTICES = 1000;
    public static final int MAXEDGES = 10000;
    public static final int MAXVERTEXVALUE = 10;
    
    private int edgeCounter = 0;
    
    public int values[] = new int[MAXVERTICES];
    public int grade[] = new int[MAXVERTICES];
    public int w[][] = new int[MAXVERTICES][MAXVERTICES];
    public int adj[][] = new int[MAXVERTICES][MAXVERTICES];
    public String teams[] = new String[MAXVERTICES];
    public int visited[] = new int[MAXVERTICES];
    public boolean known[] = new boolean[MAXVERTICES];
    public String integer2vertex[] = new String[MAXVERTICES];  
    
    private int maxVerticesSim = MAXVERTICES-1;
    private int maxEdgesSim = MAXEDGES-1;
    
    private boolean sumVertexCalculated = false;
    private int sumVertex = 1;
    private int averageVertex = 1;
    private boolean allVertexProbed = false;
    
    
    public Graph() {
        //Graph initialization
        for (int i = 0; i < MAXVERTICES; i++) {
            values[i] = NULL; //Every vertex not probed has -1
            grade[i]  = 0; //The initial grade of each vertex is 0
            teams[i] = "none";
            integer2vertex[i] = "v" + i;
            visited[i] = NULL;
            known[i] = false;
            for (int j = 0; j < MAXVERTICES; j++) {
                w[i][j] = INF; //The initial weight of each edge if INFINITE 
            }
        }
    }
    
    public int vertex2Integer(String vertex) {
        return Integer.valueOf(vertex.substring(1, vertex.length()));
    }
    
    public void addVertex(String vertexV, String team) {
        int v = vertex2Integer(vertexV);
        
        teams[v] = team;
    }
    
    public void resetTeamsVertice() {
        for (int v = 0; v <= getSize(); v++) {
            teams[v] = "none";
        }
    }
    
    public void addEdge(String vertexU, String vertexV, int weight) {
        //Get the id of each vertex
        int u = vertex2Integer(vertexU);
        int v = vertex2Integer(vertexV);
        
        if (w[u][v] == INF && weight != INF) {
            //Add the weight of the edge
            w[u][v] = w[v][u] = weight;
            //Add the edge into the graph and increase the grade of each vertex
            
            adj[u][grade[u]++] = v;
            adj[v][grade[v]++] = u;
            edgeCounter++;
            
            known[u] = true;
            known[v] = true;
        } else if (weight < w[u][v]) {
            //Add the weight of the edge
            w[u][v] = w[v][u] = weight;
            
            known[u] = true;
            known[v] = true;
        }
    }
    
    public void addEdgeSync(int u, int v, int weight) {     
        if (w[u][v] == INF && weight != INF) {
            //Add the weight of the edge
            w[u][v] = w[v][u] = weight;
            //Add the edge into the graph and increase the grade of each vertex
            
            adj[u][grade[u]++] = v;
            adj[v][grade[v]++] = u;
            edgeCounter++;
            
            known[u] = true;
            known[v] = true;
        } else if (weight < w[u][v]) {
            //Add the weight of the edge
            w[u][v] = w[v][u] = weight;
            
            known[u] = true;
            known[v] = true;
        }
    }

    public void setVertexValue(String vertexV, int value) {
        //Get the id of each vertex
        int v = vertex2Integer(vertexV);
        
        //Update the value of the vertex
        values[v] = value;
    }
    
    public void setVertexVisited(String vertexV, int step) {
        //Get the id of each vertex
        int v = vertex2Integer(vertexV);
        
        //Update the value of the vertex
        visited[v] = step;
    }
    
    public int getSize() {
        return maxVerticesSim;
    }
    
    public List<String> getShortestPath(String vertexS, String vertexD) {
        LinkedList<String> result = null;
        DijkstraAlgorithm dijkstra = new DijkstraAlgorithm();
        
        int s = vertex2Integer(vertexS);
        int d = vertex2Integer(vertexD);
        
        List<Integer> resultDijkstra = dijkstra.execute(this, s, d);
        
        result = new LinkedList<String>();
        
        if(resultDijkstra != null) {
            for (int i : resultDijkstra) {
                result.addFirst(integer2vertex[i]);
            }
        }
        
        return result;
    }
    
    public List<String> getShortestPathDijkstraComplete(String vertexS, List<String> vertexD) {
        LinkedList<String> result = null;
        DijkstraAlgorithmComplete dijkstra = new DijkstraAlgorithmComplete();
        
        List<Integer> listD = new LinkedList<Integer>();
        
        int s = vertex2Integer(vertexS);
        
        for (String v : vertexD) {
            listD.add(vertex2Integer(v));
        }
        
        List<Integer> resultDijkstra = dijkstra.execute(this, s, listD);
        
        result = new LinkedList<String>();
        
        if(resultDijkstra != null) {
            for (int i : resultDijkstra) {
                result.addFirst(integer2vertex[i]);
            }
        }
        
        return result;
    }
    
    public List<String> getShortestPathBFSComplete(String vertexS, List<String> vertexD) {
        LinkedList<String> result = null;
        BFSAlgorithm bfs = new BFSAlgorithm();
        
        List<Integer> listD = new LinkedList<Integer>();
        
        int s = vertex2Integer(vertexS);
        
        for (String v : vertexD) {
            listD.add(vertex2Integer(v));
        }
        
        List<Integer> resultBFS = bfs.execute(this, s, listD);
        
        result = new LinkedList<String>();
        
        if(resultBFS != null) {
            for (int i : resultBFS) {
                result.addFirst(integer2vertex[i]);
            }
        }
        
        return result;
    }
    
    public List<String> getBestCoverage(int depth) {
        List<String> result = null;
        BestCoverageInterface bestCoverage;
        int paramInt;
        if (getMaxEdges() / (double) getMaxVertices() > 2) {
            bestCoverage = new BestCoverage();
            paramInt = depth;
        } else {
            bestCoverage = new BestCoverageFewEdges();
            paramInt = depth * 10;
        }

        List<Integer> list = bestCoverage.execute(this, paramInt);
        
        if (list.size() > 0) {
            result = new ArrayList<String>();
            
            result.add(0, integer2vertex[list.get(0)]);
            result.add(1, String.valueOf(list.get(1)));
        }
        
        return result;
    }
    
    public List<String> getBestCoverage(int depth, String vertexIgnore) {
        List<String> result = null;
        BestCoverageInterface bestCoverage;
        int paramInt;
        if (getMaxEdges() / (double) getMaxVertices() > 1) { //TODO serah que novo algoritmo é melhor?
            bestCoverage = new BestCoverage();
            paramInt = depth;
        } else {
            bestCoverage = new BestCoverageFewEdges();
            paramInt = depth * 10;
        }

        List<Integer> list = bestCoverage.execute(this, paramInt, vertex2Integer(vertexIgnore));
        
        if (list.size() > 0) {
            result = new ArrayList<String>();
            
            result.add(0, integer2vertex[list.get(0)]);
            result.add(1, String.valueOf(list.get(1)));
        }
        
        return result;
    }
    
    public List<String> getNeighborhood(String vertex, int depth) { 
        List<String> result = null;
        NeighborhoodInterface bestCoverage;
        
        int paramInt;
        if (getMaxEdges() / (double) getMaxVertices() > 1) { //TODO serah que novo algoritmo é melhor?
            bestCoverage = new Neighborhood();
            paramInt = depth;
        } else {
            bestCoverage = new NeighborhoodFewEdges();
            paramInt = (depth + 1) * 6;
        }
        
        
        int s = vertex2Integer(vertex);
        List<Integer> list = bestCoverage.execute(this, s, paramInt);
        
        if (list.size() > 0) {
            result = new LinkedList<String>();
            for (int i : list) {
                result.add(integer2vertex[i]);
            }
        }
        
        return result;
    }
    
    public String getTeamAtVertex(String vertexV) {
        //Get the id of the vertex
        int v = vertex2Integer(vertexV);
        
        return teams[v];
    }
    
    public int getGrade(String vertexV) {
        //Get the id of the vertex
        int v = vertex2Integer(vertexV);
        
        return grade[v];
    }
    
    public int getVertexValue(String vertexV) {
        //Get the id of the vertex
        int v = vertex2Integer(vertexV);
        
        return values[v];
    }
    
    public int getVertexVisited(String vertexV) {
        //Get the id of the vertex
        int v = vertex2Integer(vertexV);
        
        return visited[v];
    }
    
    public String getAdj(String vertexU, int index) {
        //Get the id of the vertex
        int u = vertex2Integer(vertexU);
        
        int v = adj[u][index];
        return integer2vertex[v];
    }
    
    public int getWeight(String vertexU, int index) {
        //Get the id of the vertex
        int u = vertex2Integer(vertexU);
        
        int v = adj[u][index];
        return w[u][v];
    }
    
    public List<String> getVertexByValue(int value) {
        List<String> list = new ArrayList<String>();
        
        for (int v = 0; v < getSize(); v++) {
            if (values[v] == value) {
                list.add(integer2vertex[v]);
            }
        }
        
        return list;
    }
    
    public void setMaxEdges(int maxEdges) {
        this.maxEdgesSim = maxEdges;
    }
    
    public void setMaxVertices(int maxVertices) {
        this.maxVerticesSim = maxVertices;
    }
    
    public int getMaxVertices() {
        return maxVerticesSim;
    }
    
    public int getMaxEdges() {
        return maxEdgesSim;
    }
    
    public int getEdges() {
        return edgeCounter;
    }
    
    public boolean thereIsUnprobedVertex() {
        if (allVertexProbed)
            return false;
        
        if (edgeCounter == 0)
            return true;
        
        for (int v = 0; v < getSize(); v++) {
            if (values[v] == Graph.NULL) {
                return true;
            }
        }
        
        allVertexProbed = true;
        return false;
    }
    
    private void calcStatVertices() {
        if (sumVertexCalculated)
            return;
        
        int total = 0;
        int qtde = 0;
        for (int v = 0; v < getSize(); v++) {
            if (values[v] != Graph.NULL) {
                total += values[v];
                qtde++;
            }
        }
        
        sumVertex = total;
        if (qtde > 0)
            averageVertex = total / qtde;
        if (allVertexProbed || !thereIsUnprobedVertex())
            sumVertexCalculated = true;     
    }
    
    public int getSumVertices() {
        calcStatVertices();
        return sumVertex;
    }
    
    public int getAverageVertex() {
        calcStatVertices();
        return averageVertex;
    }
    
    public List<String> getAllVertices() {
        ArrayList<String> vertexList = new ArrayList<String>();
        
        for (int v = 0; v < getSize(); v++) {
            if (grade[v] > 0) {
                vertexList.add(integer2vertex[v]);
            }
        }
        
        return vertexList;
    }
    
    public List<PairPivot> getAllPivots(int amount) {
        PivotAlgorithm p = new PivotAlgorithm();
        return p.execute(this, amount);
    }
    
    public List<PairPivot> getAllPivotsIgnoringVertices(int amount, List<String> listVerticesIgnore) {
        List<Integer> listVerticesIgnoreInt = new LinkedList<Integer>();
        
        for (String v : listVerticesIgnore) {
            listVerticesIgnoreInt.add(vertex2Integer(v));
        }
        
        PivotAlgorithm p = new PivotAlgorithm();
        p.setVerticesToIgnore(listVerticesIgnoreInt);
        return p.execute(this, amount);
    }
    
    public List<PairPivot> getAllPivotsJustSomeVertices(int amount, List<String> listVertices) {
        List<Integer> listVerticesInt = new LinkedList<Integer>();
        
        for (String v : listVertices) {
            listVerticesInt.add(vertex2Integer(v));
        }
        
        PivotAlgorithm p = new PivotAlgorithm();
        p.setVerticesToJustUse(listVerticesInt);
        return p.execute(this, amount);
    }
    
    public List<Island> getAllIslands(int amount) {
        IslandAlgorithm p = new IslandAlgorithm();
        return p.execute(this, amount);
    }
    
    public int getDistance(String vertexS, String vertexD) {
        DistanceAlgorithm distance = new DistanceAlgorithm();
        
        int s = vertex2Integer(vertexS);
        int d = vertex2Integer(vertexD);
        
        return distance.execute(this, s, d);
    }
}
