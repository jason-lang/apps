package graphLib;

public class PairPivot implements Comparable {
	private int mainVertex;
	private int auxVertex;
	private int value;
	private long id;
	
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
	
	public PairPivot(int mainVertex, int auxVertex, int value, long id) {
		this.mainVertex = mainVertex;
		this.auxVertex = auxVertex;
		this.value = value;
		this.id = id;
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
