//----------------------------------------------------------------------------
// Copyright (C) 2003  Rafael H. Bordini, Jomi F. Hubner, et al.
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
// 
// To contact the authors:
// http://www.inf.ufrgs.br/~bordini
// http://www.das.ufsc.br/~jomi
//
//----------------------------------------------------------------------------

package test;

import jason.util.asl2html;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSlider;
import javax.swing.JTextPane;
import javax.swing.SwingUtilities;
import javax.swing.border.TitledBorder;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;

public class MindView  {

    public static void main(String[] args) throws Exception {
        new MindView(Integer.parseInt(args[0]));
    }
    
    private int step = 1;
    private asl2html agTransformerHtml = new asl2html("/xml/agInspection.xsl");
    private DocumentBuilder builder;
    

    public MindView(int step) throws ParserConfigurationException {
        this.step = step;
        builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        initComponents();
        show();
    }

    // Interface components
    JTextPane  jTA = null;
    JFrame     frame;
    JSlider    jHistory = null;
    
    void initComponents() {
        frame = new JFrame();

        jTA = new JTextPane();
        jTA.setEditable(false);
        jTA.setContentType("text/html");
        jTA.setAutoscrolls(false);
        
        JPanel spTA = new JPanel(new BorderLayout());
        spTA.add(BorderLayout.CENTER, new JScrollPane(jTA));
        spTA.setBorder(BorderFactory.createTitledBorder(BorderFactory
                .createEtchedBorder(), "Agent Inspection", TitledBorder.LEFT, TitledBorder.TOP));

        JPanel pAg = new JPanel(new BorderLayout());
        pAg.add(BorderLayout.CENTER, spTA);
        

        JButton jBtNext = new JButton("Next");
        jBtNext.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                SwingUtilities.invokeLater(new Runnable() {
                    public void run() {
                        step++;
                        show();
                    }
                });
            }
        });
        JButton jBtPrev = new JButton("Previous");
        jBtPrev.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                SwingUtilities.invokeLater(new Runnable() {
                    public void run() {
                        step--;
                        show();
                    }
                });
            }
        });
        JPanel pButtons = new JPanel(new FlowLayout(FlowLayout.CENTER));
        pButtons.add(jBtPrev);
        pButtons.add(jBtNext);


        JPanel pHistory = new JPanel(new BorderLayout());//new FlowLayout(FlowLayout.CENTER));
        pHistory.setBorder(BorderFactory.createTitledBorder(BorderFactory
                .createEtchedBorder(), "Agent History", TitledBorder.LEFT, TitledBorder.TOP));
        jHistory = new JSlider();
        jHistory.setMaximum(1);
        jHistory.setMinimum(0);
        jHistory.setValue(0);
        jHistory.setPaintTicks(true);
        jHistory.setPaintLabels(true);
        jHistory.setMajorTickSpacing(10);
        jHistory.setMinorTickSpacing(1);
        setupSlider();
        jHistory.addChangeListener(new ChangeListener() {
            public void stateChanged(ChangeEvent e) {
                step = (int)jHistory.getValue();
                show();
            }
        });
        pHistory.add(BorderLayout.CENTER, jHistory);
        pHistory.add(BorderLayout.EAST, pButtons);
        
        frame.getContentPane().add(BorderLayout.SOUTH, pHistory);
        frame.getContentPane().add(BorderLayout.CENTER, pAg);
        frame.pack();
        Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        int height = (int)(screenSize.height * 0.618);
        frame.setBounds(80, 30, (int)(height*1.2), height);
        
        frame.setVisible(true);
    }

    private void show() {
        try {
            frame.setTitle(":: Jason Mind Inspector :: "+step+" ::");
            Document agState = builder.parse("tmp-ag-mind/"+step+".xml");
            jTA.setText(agTransformerHtml.transform(agState));
            jHistory.setValue(step);
        } catch (Exception et) {
            et.printStackTrace();
        }
    }

    private void setupSlider() {
        int first = -1;
        int size = 0;
        for (String f: new File("tmp-ag-mind").list()) {
            if (f.endsWith(".xml")) {
                f = f.substring(0, f.length()-4);
                try {
                    int n = Integer.parseInt(f);
                    if (first < 0)
                        first = n;
                    if (n > size)
                        size = n;
                } catch (Exception e) { }
            }
        }
        step = first;
        jHistory.setMinimum(first);
        jHistory.setMaximum(size);
        jHistory.setValue(step);
    }
}
