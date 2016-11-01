package graphLib;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class PivotAlgorithm {
	private List<PairPivot> pairs = new ArrayList<PairPivot>();
	private boolean map[][] = new boolean[Graph.MAXVERTICES][Graph.MAXVERTICES]; //inicialized with false
	private long primes[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47}; //Used to create id, without clash. It must have around 6 vertex at most, otherwise it can get overflow.
	//private long primes[] = {32869, 467, 271787, 1471, 32869, 9749, 150559, 25121, 662369, 66529, 631, 516349, 71257, 547, 125201, 2239}; //Used to create an id, it is rare to clash with different numbers.
	private Set<Long> ids = new HashSet<Long>();
	private Set<Integer> idsVertices = new HashSet<Integer>();
	
	public List<PairPivot> execute(Graph g, int amount) {
		
		int u, v, i, j, w, k, x;
		int value;
		long id;
		int p;
		
		//for each possible vertex pivot u
		for (u = 0; u <= g.getSize(); u++) {

			//using v as intermediary vertex
			for (i = 0; i < g.grade[u]; i++) {
				v = g.adj[u][i];
				
				//and w as possible vertex aux
				for (j = 0; j < g.grade[v]; j++) {
					w = g.adj[v][j];
					
					if (u == w || map[u][w] || map[w][u]) continue;
					map[u][w] = true;
					
					//check all vertices x between w and u and put in the list
					value = 0;
					id = 1;
					p = 0;
					for (k = 0; k < g.grade[u]; k++) {
						x = g.adj[u][k];
						
						//there is a link between u~x~w
						if (g.w[x][w] != Graph.INF) {
							if (g.values[x] == Graph.NULL)
								value++;
							else
								value += g.values[x];
							id *= primes[p++] * x;
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
						pairs.add(new PairPivot(u, w, value, id));
						ids.add(id);
					}
				}
			}
		}
		
		Collections.sort(pairs);
		List<PairPivot> pairsResult = new ArrayList<PairPivot>();
		
		for (PairPivot pair : pairs) {
			if (amount == 0) break;
			
			if (idsVertices.contains(pair.getMainVertex()) || idsVertices.contains(pair.getAuxVertex())) 
				continue;
			amount--;
			pairsResult.add(pair);
			
			idsVertices.add(pair.getMainVertex());
			idsVertices.add(pair.getAuxVertex());
		}
		
		return pairsResult;
	}
}
