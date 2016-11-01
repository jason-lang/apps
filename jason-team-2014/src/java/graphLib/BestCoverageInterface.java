package graphLib;

import java.util.ArrayList;

public interface BestCoverageInterface {
    public ArrayList<Integer> execute(Graph g, int paramInt);
    public ArrayList<Integer> execute(Graph g, int paramInt, int vertexIgnore);
}
