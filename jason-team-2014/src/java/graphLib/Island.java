package graphLib;

import java.util.ArrayList;
import java.util.List;

public class Island implements Comparable {
    private int cutVertex;
    private List<Integer> vertices = new ArrayList<Integer>();
    private int value = 0;
    
    public Island(int cutVertex) {
        this.cutVertex = cutVertex;
    }
    
    public int getValue() {
        return value;
    }
    
    public void setValue(int value) {
        this.value = value;
    }
    
    public int getCutVertex() {
        return cutVertex;
    }
    
    public List<Integer> getVertices() {
        return vertices;
    }
    
    public void addVertex(int v) {
        vertices.add(v);
    }
    
    public int compareTo(Object o) {
        if (this.equals(o)) return 0;
        
        Island v1 = (Island) o;
        if (v1.getValue() < this.value || 
           (v1.getValue() == this.value && v1.getCutVertex() > this.cutVertex)) {
            return -1;
        } else {
            return 1;
        }
    } 
    
    @Override
    public boolean equals(Object o) {
        Island v1 = (Island) o;
        
        return v1.getCutVertex() == this.cutVertex;
    }
    
    public int getSize() {
        return vertices.size();
    }
}
