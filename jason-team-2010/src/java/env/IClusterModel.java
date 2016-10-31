package env;
import jia.Vec;
import java.util.Map;

public interface IClusterModel {
	public void setCows(Cow[] c,int H,int W);
	public void update();
	public int[] getAlloc();
	public Vec[] getCenters();
	public int[][] getData();
	public int[] getMap();
	public int[] getMaxDist();
	public int getNumberOfCluster();
	public int[] getNumCows();
	public void insertTree(int x, int y);
	public void setStepcl(int step);
	public void changeClusterer(int clusterer);
	public void changeMaxDist(int a); 
	public void changeWCprop(int radius,int nCows);
	public int getPrefRadius();
	public int getPrefNCows();
	public void changePTCprop(int k);
	public double getPrefkPTC();

}
