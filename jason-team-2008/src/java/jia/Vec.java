package jia;

import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import arch.LocalWorldModel;


public final class Vec implements Cloneable, Comparable<Vec> {
    
    // immutable fields (for a immutable object)
    public final double x,y;
    public final double r,t;
    
    public static final double PI2 = 2.0 * Math.PI;
    
    public Vec(double x, double y) {
        this.x = x;
        this.y = y;
        this.r = Math.sqrt(x*x + y*y);
        this.t = Math.atan2(y,x);
    }

    /** create a vector based on a location in the model */
    public Vec(LocalWorldModel model, Location l) {
        this.x = l.x;
        this.y = model.getHeight()-l.y-1;
        this.r = Math.sqrt(x*x + y*y);
        this.t = Math.atan2(y,x);
    }
    
    /** create a vector based on a location in the model */
    public Vec(LocalWorldModel model, int x, int y) {
        this.x = x;
        this.y = model.getHeight()-y-1;
        this.r = Math.sqrt(x*x + this.y*this.y);
        this.t = Math.atan2(this.y,x);
    }
    
    public int getX() { return (int)Math.round(x); }
    public int getY() { return (int)Math.round(y); }
    public double magnitude() { return r; }
    public double angle()     { return t; }
    
    public Location getLocation(LocalWorldModel model) {
        return new Location(getX(), model.getHeight()-getY()-1); 
    }
    
    public Vec add(Vec v) {
        return new Vec(x + v.x, y + v.y);
    }
    public Vec sub(Vec v) {
        return new Vec(x - v.x, y - v.y);
    }
    public Vec product(double e) {
        return new Vec( x * e, y * e);
    }
    public Vec newAngle(double t) {
        while (t > PI2) t = t - PI2;
        while (t < 0)   t = t + PI2;
        return new Vec(r*Math.cos(t), r*Math.sin(t));       
    }
    
    /** turn the vec to 90 degrees clockwise */
    public Vec turn90CW() {
        return new Vec(y, -x);
    }
    /** turn the vec to 90 degrees anticlockwise */
    public Vec turn90ACW() {
        return new Vec(-y, x);      
    }
    
    public Vec newMagnitude(double r) {
        return new Vec(r*Math.cos(t), r*Math.sin(t));
    }

    /**
     * Provides info on which octant (0-7) the vector lies in.
     * 0 indicates 0 radians +- PI/8 1-7 continue CCW.
     * @return 0 - 7, depending on which direction the vector is pointing.
     */
    public int octant() {
        double  temp = t + Math.PI/8;
        if (temp<0) 
            temp += Math.PI*2;
        return ((int)(temp/(Math.PI/4))%8);
    }

    /**
     * Provides info on which quadrant (0-3) the vector lies in.
     * 0 indicates 0 radians +- PI/4 1-3 continue CCW.
     * @return 0 - 3, depending on which direction the vector is pointing.
     */
    public int quadrant() {
        double temp = t + Math.PI/4;
        if (temp<0) temp += Math.PI*2;
        return ((int)(temp/(Math.PI/2))%4);
    }

    @Override
    public int hashCode() {
        return (int)((x + y) * 37);
    }
    
    @Override
    public boolean equals(Object o) {
        if (o == null) return false;
        if (o == this) return true;
        if (o instanceof Vec) {
            Vec v = (Vec)o;
            return (getX() == v.getX()) && (getY() == v.getY());
        }
        return false;
    }
    
    public int compareTo(Vec o) {
        if (r > o.r) return 1;
        if (r < o.r) return -1;
        return 0;
    }

    public Object clone() {
        return this; // it is an immutable object, no need to create a new one
    }

    
    @Override
    public String toString() {
        return getX() + "," + getY();
    }

    //
    // Useful static methods for list of vecs
    //
    
    public static Vec max(Collection<Vec> vs) {
        Vec max = null;
        for (Vec v: vs) {
            if (max == null || max.r < v.r)
                max = v;
        }
        return max;
    }

    public static List<Vec> sub(Collection<Vec> vs, Vec ref) {
        List<Vec> r = new ArrayList<Vec>(vs.size());
        for (Vec v: vs) {
            r.add(v.sub(ref));
        }
        return r;
    }
    
    /*
    public static List<Vec> cluster(List<Vec> vs, int maxstddev) {
        vs = new ArrayList<Vec>(vs); // result vectors in the cluster
        Vec mean   = Vec.mean(vs);
        Vec stddev = Vec.stddev(vs, mean);
        
        // remove max if stddev is too big
        while (stddev.magnitude() > maxstddev) {
            Vec max  = Vec.max(Vec.sub(vs, mean));
            vs.remove(max.add(mean));
            mean   = Vec.mean(vs);
            stddev = Vec.stddev(vs, mean);
        }
        return vs;
    }
    */

    public static Vec mean(Collection<Vec> vs) {
        if (vs.isEmpty())
            return new Vec(0,0);
        double x = 0, y = 0;
        for (Vec v: vs) {
            x += v.x;
            y += v.y;
        }
        return new Vec(x/vs.size(), y/vs.size());  
    }
    
    public static Vec stddev(Collection<Vec> vs, Vec mean) {
        if (vs.isEmpty())
            return new Vec(0,0);
        double x = 0, y = 0;
        for (Vec v: vs) {
            x += Math.pow(v.x - mean.x, 2);
            y += Math.pow(v.y - mean.y, 2);
        }
        x = x / vs.size();
        y = y / vs.size();
        
        return new Vec( Math.sqrt(x), Math.sqrt(y));
    }

}
