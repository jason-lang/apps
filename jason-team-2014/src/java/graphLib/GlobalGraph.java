package graphLib;

import java.util.HashSet;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

public class GlobalGraph {
    private static GlobalGraph globalGraph = new GlobalGraph();
    private Graph graph;
    private String positions[] = new String[29];
    private Map<String, String> positionsEnemies;
    private Island biggestIslandArt[] = new Island[Graph.MAXVERTICES];
    private Set<String> enemiesVertices[] = new HashSet[Graph.MAXVERTICES];
    
    private GlobalGraph() {
        graph = new Graph();
        
        for (int i = 0; i < 29; i++) {
            positions[i] = null;
        }
        
        for (int i = 0; i < Graph.MAXVERTICES; i++) {
            biggestIslandArt[i] = null;
            enemiesVertices[i] = null;
        }
        
        positionsEnemies = new ConcurrentHashMap<String, String>();
    }
    
    public static GlobalGraph getInstance() {
        return globalGraph;
    }
    
    public synchronized void reset() {
        if (graph.getEdges() > 0)
            graph = new Graph();
        positionsEnemies.clear();
        for (int i = 0; i < 29; i++) {
            positions[i] = null;
        }
        for (int i = 0; i < Graph.MAXVERTICES; i++) {
            biggestIslandArt[i] = null;
            enemiesVertices[i] = null;
        }
    }
    
    public synchronized void addEdge(String vertexU, String vertexV, int weight) {
        graph.addEdge(vertexU, vertexV, weight);
    }
    
    public Graph getGraph() {
        return graph;
    }
    
    public void setIsland(int v, Island island) {
        biggestIslandArt[v] = island;
    }
    
    public Island getIsland(int v) {
        return biggestIslandArt[v];
    }
    
    public String getPosition(int id) {
        return positions[id];
    }
    
    public void setPosition(int id, String pos) {
        positions[id] = pos;
    }
    
    public void addEnemyPosition(int id, String enemy, String vertex) {
        //Remove the old position
        String oldVertex = positionsEnemies.get(enemy);
        if (oldVertex != null && !oldVertex.equals(vertex)) {
            //Remove of the list of vertices
            int v = graph.vertex2Integer(oldVertex);
            if (enemiesVertices[v] != null)
                enemiesVertices[v].remove(enemy);
        }
        
        if (!vertex.equals(oldVertex)) {
            positionsEnemies.put(enemy, vertex);
            
            //Add in the list of vertices
            int v = graph.vertex2Integer(vertex);
            Set<String> setEnemiesAtVertex = enemiesVertices[v];
            if (setEnemiesAtVertex == null) {
                setEnemiesAtVertex = new HashSet<String>();
                enemiesVertices[v] = setEnemiesAtVertex;
            }
            setEnemiesAtVertex.add(enemy);
        }
    }
    
    public void remEnemyPosition(int id, String enemy) {
        String vertex = positionsEnemies.remove(enemy);
        
        if (vertex != null) {
            //Remove of the list of vertices
            int v = graph.vertex2Integer(vertex);
            if (enemiesVertices[v] != null)
                enemiesVertices[v].remove(enemy);
        }
    }
    
    public String getEnemyPosition(String enemy) {
        return positionsEnemies.get(enemy);
    }
    
    public Map<String, String> getMapEnemiesFromId() {
        return positionsEnemies;
    }
    
    public Set<String> getMapEnemiesByPosition(String vertex) {
        return enemiesVertices[graph.vertex2Integer(vertex)];
    }
    
    public void cleanPosition(int id, String vertex) {
        for (Entry<String, String> entry : positionsEnemies.entrySet()) {
            if (entry.getValue().equals(vertex)) {
                positionsEnemies.remove(entry.getKey());
            }
        }
    }
}

