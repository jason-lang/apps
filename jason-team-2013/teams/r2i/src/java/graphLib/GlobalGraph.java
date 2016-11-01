package graphLib;

import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

public class GlobalGraph {
	private static GlobalGraph globalGraph = new GlobalGraph();
	private Graph graph;
	private String positions[] = new String[29];
	private Map<String, String> positionsEnemies;
	private Island biggestIslandArt[] = new Island[Graph.MAXVERTICES];
	
	private GlobalGraph() {
		graph = new Graph();
		
		for (int i = 0; i < 29; i++) {
			positions[i] = null;
		}
		
		for (int i = 0; i < Graph.MAXVERTICES; i++) {
			biggestIslandArt[i] = null;
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
		positionsEnemies.put(enemy, vertex);
	}
	
	public void remEnemyPosition(int id, String enemy) {
		positionsEnemies.remove(enemy);
	}
	
	public Map<String, String> getMapEnemiesFromId(int id) {
		return positionsEnemies;
	}
	
	
	public void cleanPosition(int id, String vertex) {
		for (Entry<String, String> entry : positionsEnemies.entrySet()) {
			if (entry.getValue().equals(vertex)) {
				positionsEnemies.remove(entry.getKey());
			}
		}
	}
}

