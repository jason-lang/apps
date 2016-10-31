package jasonteam;

public class Location {
    public int x = -1,
               y = -1;
    
    public Location(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    public int distance(Location l) {
        return Math.abs(x - l.x) + Math.abs(y - l.y);
    }

    public  boolean isNeigbour(Location l) {
        return 
            distance(l) == 1 ||
            equals(l) ||
            Math.abs(x - l.x) == 1 && Math.abs(y - l.y) == 1;
    }
    
    public boolean equals(Object o) {
        try {
            Location l = (Location)o;
            return l.x == x && l.y == y;
        } catch (Exception e) {  }
        return false;
    }
    
    public String toString() {
    	return (x + "," + y);
    }
}
