package test;


import jia.Vec;

import org.junit.*;

import env.ClusterModel.*;

public class TestClusterSubClass {
	Cluster cl;
	@Before
	public void test1(){
		cl = new Cluster();
		int[][] data = new int[2][10];
		int dataNum = 10;
		data[0][0] = 3;data[1][0] = 4;
		data[0][1] = 5;data[1][1] = 5;
		data[0][2] = 4;data[1][2] = 6;
		data[0][3] = 4;data[1][3] = 3;
		data[0][4] = 6;data[1][4] = 4;
		data[0][5] = 6;data[1][5] = 6;
		data[0][6] = 6;data[1][6] = 3;
		data[0][7] = 7;data[1][7] = 3;
		data[0][8] = 7;data[1][8] = 2;
		data[0][9] = 8;data[1][9] = 5;
		cl.setCows(data, dataNum);
		cl.calculateProperties(1);
		
	}
	
	
	@Test
	public void calculatinCenter(){
		System.out.println(""+cl.getCenter().x+", "+cl.getCenter().y);
	}
	@Test
	public void calculatinDiferentRadius(){
		cl.calculateProperties(1);
		System.out.println("Radius:\n\t1st Method: "+cl.getRadius());
		cl.calculateProperties(2);
		System.out.println("\t2nd Method: "+cl.getRadius());
		cl.calculateProperties(3);
		System.out.println("\t3th Method: "+cl.getRadius());
		cl.calculateProperties(4);
		System.out.println("\t4th Method: "+cl.getRadius());
	}
	@Test
	public void calculatinBubble(){
		cl.calculateBubble(new Vec(-1,1));
		Vec[] bubble = cl.getBubble();
		System.out.println("Bubble: \n");
		for(int i =0;i<bubble.length;i++){
			System.out.println("\t"+bubble[i].x+", "+bubble[i].y);
		}
		
	}
	
	
	
}
