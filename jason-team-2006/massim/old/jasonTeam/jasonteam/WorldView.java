package jasonteam;

import java.awt.BorderLayout;
import java.awt.Canvas;
import java.awt.Color;
import java.awt.Graphics;

import javax.swing.JFrame;

public class WorldView extends JFrame {

	private int cellSizeW = 20;
	private int cellSizeH = 20;
	MyCanvas    drawArea;

	WorldModel model;
	
	
	// singleton pattern
	private static WorldView view = null;
	public static WorldView create(WorldModel model) {
		if (view == null) {
			view = new WorldView(model);
		}
		return view;
	}
	
	public static void destroy() {
		if (view != null) {
			view.setVisible(false);
			view = null;
		}
	}

	private WorldView(WorldModel model) {
		super("Simulation global view of our agents");
		this.model = model;
		int s = 600;
		setSize(s,s);
		getContentPane().setLayout(new BorderLayout());
		drawArea = new MyCanvas();
		getContentPane().add(BorderLayout.CENTER, drawArea);
		setVisible(true);
	}
	
	public void repaint() {
		super.repaint();
		drawArea.repaint();
	}
	
	int updateCount = 0;
	public void update() {
		updateCount++;
		if (updateCount == 4) { // only the fourth agent ask draw, we realy draw
			updateCount = 0;
			repaint();
		}
	}
	
	class MyCanvas extends Canvas {
		public void paint(Graphics g) {
			cellSizeW = getWidth() / (model.width);
			cellSizeH = getHeight() / (model.height+1);
			
			g.setColor(Color.lightGray);
			for (int l=1; l<=(model.height+1); l++) {
				g.drawLine(0, l*cellSizeH, model.width*cellSizeW, l*cellSizeH);
			}
			for (int c=1; c<=model.width; c++) {
				g.drawLine(c*cellSizeW, 0, c*cellSizeW, (model.height+1)*cellSizeH);
			}
			
			for (int x=0; x<model.width; x++) {
				for (int y=0; y<model.height; y++) {
					if ((model.data[x][y] & WorldModel.OBSTACLE) != 0) {
						drawObstacle(g, x, y);
					} else {
						if ((model.data[x][y] & WorldModel.EMPTY) != 0) {
							drawEmpty(g, x, y);
						}
						if ((model.data[x][y] & WorldModel.DEPOT) != 0) {
							drawDepot(g, x, y);
						}
						if ((model.data[x][y] & WorldModel.GOLD) != 0) {
							drawGold(g, x, y);
						}
						if ((model.data[x][y] & WorldModel.ENEMY) != 0) {
							drawEnemy(g, x, y);
						}
						if ((model.data[x][y] & WorldModel.ALLY) != 0) {
							drawAlly(g, x, y);
						}
					}
				}
			}
		}
	
		public void drawEmpty(Graphics g, int x, int y) {
			g.setColor(Color.white);
			g.fillRect(x*cellSizeW+1, y*cellSizeH+1, cellSizeW-2, cellSizeH-2);
		}

		public void drawObstacle(Graphics g, int x, int y) {
			g.setColor(Color.black);
			g.drawRect(x*cellSizeW, y*cellSizeH, cellSizeW, cellSizeH);
		}
	
		public void drawDepot(Graphics g, int x, int y) {
			g.setColor(Color.gray);
			g.fillRect(x*cellSizeW,   y*cellSizeH, cellSizeW, cellSizeH);
			g.setColor(Color.pink);
			g.drawRect(x*cellSizeW+2, y*cellSizeH+2, cellSizeW-4, cellSizeH-4);
			g.drawLine(x*cellSizeW+2, y*cellSizeH+2, (x+1)*cellSizeW-2, (y+1)*cellSizeH-2);
			g.drawLine(x*cellSizeW+2, (y+1)*cellSizeH-2, (x+1)*cellSizeW-2, y*cellSizeH+2);
		}
	
		public void drawGold(Graphics g, int x, int y) {
			g.setColor(Color.yellow);
			g.drawRect(x*cellSizeW+1, y*cellSizeH+1, cellSizeW-2, cellSizeH-2);
			int[] vx = new int[4];
			int[] vy = new int[4];
			vx[0] = x*cellSizeW + (cellSizeW/2); vy[0] = y*cellSizeH;
			vx[1] = (x+1)*cellSizeW;             vy[1] = y*cellSizeH + (cellSizeH/2);
			vx[2] = x*cellSizeW + (cellSizeW/2); vy[2] = (y+1)*cellSizeH;
			vx[3] = x*cellSizeW;                 vy[3] = y*cellSizeH + (cellSizeH/2);
			g.fillPolygon(vx, vy, 4);
		}
		
		public void drawAlly(Graphics g, int x, int y) {
			g.setColor(Color.blue);
			g.fillOval(x*cellSizeW+1, y*cellSizeH+1, cellSizeW-8, cellSizeH-8);
		}
	
		public void drawEnemy(Graphics g, int x, int y) {
			g.setColor(Color.red);
			g.fillOval(x*cellSizeW+7, y*cellSizeH+7, cellSizeW-8, cellSizeH-8);
		}
	}
	
	public static void main(String[] a) throws Exception {
		WorldModel m = WorldModel.create(20,20);
		WorldView v  = WorldView.create(m);
		m.setDepot(10,10);
		m.add(m.OBSTACLE, 3,1);
		m.add(m.OBSTACLE, 3,2);
		m.add(m.OBSTACLE, 3,3);
		m.add(m.OBSTACLE, 3,4);
		m.add(m.OBSTACLE, 4,4);
		m.add(m.OBSTACLE, 5,4);
		m.add(m.OBSTACLE, 6,4);
		m.add(m.EMPTY, 10,1);
		m.add(m.EMPTY, 10,2);

		m.add(m.ALLY, 1,1);
		m.add(m.ENEMY, 1,1);
		m.add(m.GOLD, 1,2);
		m.add(m.ENEMY, 2,2);
		m.add(m.EMPTY, 1,0);
		m.add(m.OBSTACLE, 2,0);
		v.repaint();
		
		Thread.sleep(1000);
		m.clearAgView(1,1);
		v.repaint();
		
		Thread.sleep(1000);
		m.add(m.GOLD, 13,10);
		m.add(m.ALLY, 13,10);
		m.add(m.ENEMY, 0,0);
		m.add(m.EMPTY, 0,0);
		m.add(m.ALLY, 19,19);

		m.add(m.GOLD, 5,5);
		m.add(m.ALLY, 5,5);
		m.add(m.ENEMY,5,5);
		v.repaint();
	}
}
