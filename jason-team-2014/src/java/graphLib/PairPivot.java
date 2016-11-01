package graphLib;

import java.util.HashSet; 
import java.util.Set;

public class PairPivot implements Comparable {
    private int mainVertex;
    private int auxVertex;
    private int value = 0;
    private long id = 0;
    private Set<Integer> vertices = new HashSet<Integer>();
    
    public int getMainVertex() {
        return mainVertex;
    }
    
    public int getAuxVertex() {
        return auxVertex;
    }
    
    public void setMainVertex(int mainVertex) {
        this.mainVertex = mainVertex;
    }

    public void setAuxVertex(int auxVertex) {
        this.auxVertex = auxVertex;
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
    
    public Set<Integer> getVertices() {
        return vertices;
    }
    
    public boolean contains(int v) {
        return vertices.contains(v);
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
