package graphLib;

import java.util.LinkedList;
import java.util.List;

public class PairPivot implements Comparable {
	private int mainVertex;
	private int auxVertex;
	private int value = 0;
	private long id = 0;
	private List<Integer> vertices = new LinkedList<Integer>();
	
	public int getMainVertex() {
		return mainVertex;
	}
	
	public int getAuxVertex() {
		return auxVertex;
	}
	
	public int getValue() {
		return value;
	}
	
	public long getId() {
		return id;
	}
	
	public void addVertex(int v) {
		vertices.add(v);
	}
	
	public void setId(long id) {
		this.id = id;
	}
	
	public void setValue(int value) {
		this.value = value;
	}
	
	public PairPivot(int mainVertex, int auxVertex) {
		this.mainVertex = mainVertex;
		this.auxVertex = auxVertex;
	}
	
	public List<Integer> getVertices() {
		return vertices;
	}
	
	public int compareTo(Object o) {
		if (this.equals(o)) return 0;
		
    	PairPivot v1 = (PairPivot) o;
    	if (v1.getValue() < this.value || 
    	   (v1.getValue() == this.value && v1.getMainVertex() > this.mainVertex) ||
    	   (v1.getValue() == this.value && v1.getMainVertex() == this.mainVertex && v1.getAuxVertex() > this.auxVertex)) {
    		return -1;
    	} else {
    		return 1;
    	}
	} 
	
	@Override
	public boolean equals(Object o) {
		PairPivot v1 = (PairPivot) o;
		
		return v1.getValue() == this.value && v1.getMainVertex() == this.mainVertex && v1.getAuxVertex() == this.auxVertex;
	}
	
	public String toString() {
		return "(" + mainVertex + "," + auxVertex + "," + value + "," + id + ")";  
	}
}
