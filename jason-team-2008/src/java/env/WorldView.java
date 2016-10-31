package env;

import jason.environment.grid.GridWorldView;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.Graphics;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionListener;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;


/** 
 * graphical view for some world model
 * 
 * @author Jomi
 */
public class WorldView extends GridWorldView {

    private static final long serialVersionUID = 1L;

    //MiningEnvironment env = null;
    
    JLabel     jCycle;
    JLabel     jCowsC;

    JLabel     jlMouseLoc;
    //JComboBox  scenarios;
    //JSlider    jSpeed;


    public void destroy() {
        setVisible(false);
    }

    public WorldView(WorldModel model, int windowSize) {
        this("Herding World", model, windowSize);
    }
    
    public WorldView(String title, WorldModel model) {
        this(title,model,800);
    }
    
    public WorldView(String title, WorldModel model, int windowSize) {
        super(model, title, windowSize);
        setVisible(true);
        repaint();
    }
    
    @Override
    public void initComponents(int width) {
        super.initComponents(width);
        
        
        JPanel args = new JPanel();
        args.setLayout(new BoxLayout(args, BoxLayout.Y_AXIS));

        /*
        scenarios = new JComboBox();
        for (int i=1; i<=13; i++) {
            scenarios.addItem(i);
        }

        JPanel sp = new JPanel(new FlowLayout(FlowLayout.LEFT));
        sp.setBorder(BorderFactory.createEtchedBorder());
        sp.add(new JLabel("Scenario:"));
        sp.add(scenarios);
        
        jSpeed = new JSlider();
        jSpeed.setMinimum(0);
        jSpeed.setMaximum(400);
        jSpeed.setValue(50);
        jSpeed.setPaintTicks(true);
        jSpeed.setPaintLabels(true);
        jSpeed.setMajorTickSpacing(100);
        jSpeed.setMinorTickSpacing(20);
        jSpeed.setInverted(true);
        Hashtable<Integer,Component> labelTable = new Hashtable<Integer,Component>();
        labelTable.put( 0, new JLabel("max") );
        labelTable.put( 200, new JLabel("speed") );
        labelTable.put( 400, new JLabel("min") );
        jSpeed.setLabelTable( labelTable );
        JPanel p = new JPanel(new FlowLayout());
        p.setBorder(BorderFactory.createEtchedBorder());
        p.add(jSpeed);
        
        args.add(sp);
        args.add(p);
        */

        JPanel msg = new JPanel();
        msg.setLayout(new BoxLayout(msg, BoxLayout.Y_AXIS));
        msg.setBorder(BorderFactory.createEtchedBorder());
        
        
        JPanel pmoise = new JPanel(new FlowLayout(FlowLayout.CENTER));
        //p.add(new JLabel("Click on the cells to add new pieces of gold."));
        //pmoise.add(new JLabel("  (mouse at:"));
        jlMouseLoc = new JLabel("0,0");
        pmoise.add(jlMouseLoc);
        pmoise.setBorder(BorderFactory.createEtchedBorder());
        //msg.add(p);
        
        JPanel p = new JPanel(new FlowLayout(FlowLayout.CENTER));
        p.add(new JLabel("Cycle:"));
        jCycle = new JLabel("0");
        p.add(jCycle);
        
        p.add(new JLabel("        Cows in corral (blue x red):"));
        jCowsC = new JLabel("0");
        p.add(jCowsC);

        msg.add(p);
        
        JPanel s = new JPanel(new BorderLayout());
        s.add(BorderLayout.WEST, args);
        s.add(BorderLayout.CENTER, msg);
        s.add(BorderLayout.EAST, pmoise);
        getContentPane().add(BorderLayout.SOUTH, s);        

        // Events handling
        /*
        jSpeed.addChangeListener(new ChangeListener() {
            public void stateChanged(ChangeEvent e) {
                //if (env != null) {
                //    env.setSleep((int)jSpeed.getValue());
                //}
            }
        });

        scenarios.addItemListener(new ItemListener() {
            public void itemStateChanged(ItemEvent ievt) {
                int w = ((Integer)scenarios.getSelectedItem()).intValue();
                if (env != null && env.getSimId() != w) {
                    env.startNewWorld(w);
                }
            }            
        });
        */
        
        /*
        getCanvas().addMouseListener(new MouseListener() {
            public void mouseClicked(MouseEvent e) {
                int col = e.getX() / cellSizeW;
                int lin = e.getY() / cellSizeH;
                if (col >= 0 && lin >= 0 && col < getModel().getWidth() && lin < getModel().getHeight()) {
                    WorldModel wm = (WorldModel)model;
                    wm.add(WorldModel.COW, col, lin);
                    //wm.setInitialNbGolds(wm.getInitialNbGolds()+1);
                    update(col, lin);
                }
            }
            public void mouseExited(MouseEvent e) {}
            public void mouseEntered(MouseEvent e) {}
            public void mousePressed(MouseEvent e) {}
            public void mouseReleased(MouseEvent e) {}
        });
        */

        getCanvas().addMouseMotionListener(new MouseMotionListener() {
            public void mouseDragged(MouseEvent e) { }
            public void mouseMoved(MouseEvent e) {
                int col = e.getX() / cellSizeW;
                int lin = e.getY() / cellSizeH;
                if (col >= 0 && lin >= 0 && col < getModel().getWidth() && lin < getModel().getHeight()) {
                    jlMouseLoc.setText(col+","+lin);
                }
            }            
        });
    }
    
    /*
    public void setEnv(MiningEnvironment env) {
        this.env = env;
        scenarios.setSelectedIndex(env.getSimId()-1);
    }
    */
    
    public void setCycle(int c) {
        if (jCycle != null) {
            WorldModel wm = (WorldModel)model;
            
            String steps = "";
            if (wm.getMaxSteps() > 0) {
                steps = "/" + wm.getMaxSteps();
            }
            jCycle.setText(c+steps);
            
            jCowsC.setText(wm.getCowsBlue() + " x " + wm.getCowsRed()); // + "/" + wm.getInitialNbGolds());    
        }
    }
    
    @Override
    public void draw(Graphics g, int x, int y, int object) {
        switch (object) {
        case WorldModel.CORRAL:   drawCorral(g, x, y);  break;
        case WorldModel.COW:    drawCow(g, x, y);  break;
        case WorldModel.ENEMY:   drawEnemy(g, x, y);  break;
        case WorldModel.TARGET:  drawTarget(g, x, y);  break;
        case WorldModel.FORPLACE:  drawFormPlace(g, x, y);  break;
        }
    }

    /*
    Color[] agColor = { Color.blue,
                        new Color(249,255,222),
                        Color.orange, //new Color(228,255,103),
                        new Color(206,255,0) } ;
    Color[] idColor = { Color.white,
                        Color.black,
                        Color.darkGray,
                        Color.red } ;
    */
    
    @Override
    public void drawAgent(Graphics g, int x, int y, Color c, int id) {
        g.setColor(c);
        g.fillOval(x * cellSizeW + 2, y * cellSizeH + 2, cellSizeW - 4, cellSizeH - 4);
        if (id >= 0) {
            g.setColor(Color.white);
            drawString(g, x, y, defaultFont, String.valueOf(id+1));
        }
    }
    
    
    /*
    @Override
    public void drawAgent(Graphics g, int x, int y, Color c, int id) {
        int gw = 1;
        if (id < 6) {
            // blue team
            g.setColor(Color.blue);
            g.fillOval(x * cellSizeW + gw, y * cellSizeH + gw, cellSizeW - gw*2, cellSizeH - gw*2);
            if (id >= 0) {
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, String.valueOf(id+1));
            }
        } else {
            // red team
            g.setColor(Color.red);
            g.fillOval(x * cellSizeW + gw, y * cellSizeH + gw, cellSizeW - gw*2, cellSizeH - gw*2);
            if (id >= 0) {
                g.setColor(Color.white);
                drawString(g, x, y, defaultFont, String.valueOf(id-5));
            }
        }
    }
    */

    public void drawCorral(Graphics g, int x, int y) {
        g.setColor(Color.gray);
        g.fillRect(x * cellSizeW, y * cellSizeH, cellSizeW, cellSizeH);
        g.setColor(Color.pink);
        g.drawRect(x * cellSizeW + 2, y * cellSizeH + 2, cellSizeW - 4, cellSizeH - 4);
        g.drawLine(x * cellSizeW + 2, y * cellSizeH + 2, (x + 1) * cellSizeW - 2, (y + 1) * cellSizeH - 2);
        g.drawLine(x * cellSizeW + 2, (y + 1) * cellSizeH - 2, (x + 1) * cellSizeW - 2, y * cellSizeH + 2);
    }

    public void drawTarget(Graphics g, int x, int y) {
        g.setColor(Color.darkGray);
        g.drawRect(x * cellSizeW + 2, y * cellSizeH + 2, cellSizeW - 4, cellSizeH - 4);
        g.setColor(Color.white);
        g.drawRect(x * cellSizeW + 3, y * cellSizeH + 3, cellSizeW - 6, cellSizeH - 6);
        g.setColor(Color.darkGray);
        g.drawRect(x * cellSizeW + 4, y * cellSizeH + 4, cellSizeW - 8, cellSizeH - 8);
    }

    public void drawFormPlace(Graphics g, int x, int y) {
        g.setColor(Color.green);
        g.drawRect(x * cellSizeW + 2, y * cellSizeH + 2, cellSizeW - 4, cellSizeH - 4);
        g.setColor(Color.lightGray);
        g.drawRect(x * cellSizeW + 3, y * cellSizeH + 3, cellSizeW - 6, cellSizeH - 6);
        g.setColor(Color.gray);
        g.drawRect(x * cellSizeW + 4, y * cellSizeH + 4, cellSizeW - 8, cellSizeH - 8);
    }

    public void drawCow(Graphics g, int x, int y) {
        g.setColor(Color.black);
        g.drawRect(x * cellSizeW + 2, y * cellSizeH + 2, cellSizeW - 4, cellSizeH - 4);
        g.setColor(Color.darkGray);
        g.drawRect(x * cellSizeW + 3, y * cellSizeH + 3, cellSizeW - 6, cellSizeH - 6);
        g.setColor(Color.yellow);
        g.fillRect(x * cellSizeW + 4, y * cellSizeH + 4, cellSizeW - 8, cellSizeH - 8);

        /*
        g.setColor(Color.black);
        g.drawRect(x * cellSizeW + 2, y * cellSizeH + 2, cellSizeW - 4, cellSizeH - 4);        
        boolean black = true;
        final int end = (y+1)*cellSizeH;
        for (int l = (y*cellSizeH)+1; l < end; l += 3) {
            if (black)
                g.setColor(Color.black);
            else
                g.setColor(Color.yellow);
            black = !black;
            g.fillRect(x * cellSizeW + 2, l, cellSizeW - 4, 2);        

        }
        */
        /*
        int[] vx = new int[4];
        int[] vy = new int[4];
        vx[0] = x * cellSizeW + (cellSizeW / 2);
        vy[0] = y * cellSizeH;
        vx[1] = (x + 1) * cellSizeW;
        vy[1] = y * cellSizeH + (cellSizeH / 2);
        vx[2] = x * cellSizeW + (cellSizeW / 2);
        vy[2] = (y + 1) * cellSizeH;
        vx[3] = x * cellSizeW;
        vy[3] = y * cellSizeH + (cellSizeH / 2);
        g.setColor(Color.white);
        g.fillPolygon(vx, vy, 4);
        */
    }

    public void drawEnemy(Graphics g, int x, int y) {
        int gw = 1;
        g.setColor(Color.red);
        g.fillOval(x * cellSizeW + gw, y * cellSizeH + gw, cellSizeW - gw*2, cellSizeH - gw*2);
    }
}
