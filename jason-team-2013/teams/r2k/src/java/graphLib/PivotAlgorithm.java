package graphLib;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/*
 * TODO Otimizar
 * 
 * Vértices pivô podem desencadear conflitos. Há vértices pivô que tem interssecções com outros vértices pivôs. 
 * Um deles não pode ser escolhido. Se um for escolhido, o outro não pode ser.
 * Cada vértice pivô escolhido dá um número de pontos. 
 * 
 * Dado um conjunto de N vértices pivô, seus valores e a lista de conflitos, quero o subconjunto de K vértices pivô onde eu consigo a maior somatória dos valores.
 * Ex de entrada:
 * 
 * v1 40 //vértice e valor
 * v2 74
 * v3 53
 * v4 60
 * v1 v3 //conflitos
 * v2 v4
 * 
 * Saída esperada:
 * v2 v3
 */

public class PivotAlgorithm {
	private List<PairPivot> pairs = new ArrayList<PairPivot>();
	private boolean map[][] = new boolean[Graph.MAXVERTICES][Graph.MAXVERTICES]; //inicialized with false
	private long primes[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47}; //Used to create id, without clash. It must have around 6 vertex at most, otherwise it can get overflow.
	//private long primes[] = {32869, 467, 271787, 1471, 32869, 9749, 150559, 25121, 662369, 66529, 631, 516349, 71257, 547, 125201, 2239}; //Used to create an id, it is rare to clash with different numbers.
	private Map<Long, PairPivot> ids = new HashMap<Long, PairPivot>();
	
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
					if (!ids.containsKey(id)) { //Avoid the same group of vertices
						newPivot.setValue(value);
						pairs.add(newPivot);
						ids.put(id, newPivot);
					} else {
						PairPivot oldPivot = ids.get(id);
						if (g.w[oldPivot.getMainVertex()][oldPivot.getAuxVertex()] != Graph.INF) { //Avoid connected vertices
							oldPivot.setMainVertex(newPivot.getMainVertex());
							oldPivot.setAuxVertex(newPivot.getAuxVertex());
						}
					}
				}
			}
		}
		
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
	
	private boolean validPivot(PairPivot pair) {
		for (int v : pair.getVertices()) {
			if (ignoreVertex[v]) return false;
		}
		return true;
	}
}
