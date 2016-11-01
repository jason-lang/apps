package graphLib;

public class PairPriority implements Comparable { 
    private int key;
    private int value;
    
    public PairPriority(int key, int value) {
        this.key = key;
        this.value = value;
    }
    
    public int getkey() {
        return key;
    }

    public int getValue() {
        return value;
    }

    public int compareTo(Object o) {
        PairPriority v1 = (PairPriority) o;
        
        if (v1.getValue() > this.value || (v1.getValue() == this.value && v1.getkey() > this.key)) {
            return -1;
        } else {
            return 1;
        }
    } 
    
    public boolean equals(Object o) {
        PairPriority v1 = (PairPriority) o;
        return v1.getkey() == this.key && v1.getValue() == this.value;
    }
}
