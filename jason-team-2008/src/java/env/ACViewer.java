package env;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXParseException;

public class ACViewer extends Thread {

    private static Logger logger = Logger.getLogger(ACViewer.class.getName());

    WorldModel model = null;
    WorldView  view  = null;
    
    DocumentBuilder builder = null;
    
    File massimServerBackupDir;

    public ACViewer(String massimBackDir, int w, int h) {
        massimServerBackupDir = new File(massimBackDir);

        model = new WorldModel(w,h, WorldModel.agsByTeam*2);
        view  = new WorldView("Herding Contest -- AC simulator view",model);
        model.setView(view);
    }
    
    
    File getLastFile(File dir) {
        if (dir != null) {
            File[] afiles = dir.listFiles();
            if (afiles != null && afiles.length > 0) {
                List<File> lfiles = new ArrayList<File>();
                for (File f: dir.listFiles()) {
                    lfiles.add(f);
                }
                return Collections.max(lfiles);
            } else {
                logger.info("no files in "+dir);
            }
        }
        return null;
    }
    
    void updateWorld(File f) throws Exception {
        if (builder == null) {
            builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        }

        
        Document doc = builder.parse(f);
        Element simulation = (Element)doc.getElementsByTagName("simulation").item(0); //((NodeList)expr.evaluate("//simulation[@id='"+simId+"']/configuration", doc, XPathConstants.NODESET)).item(0);
        view.setCycle(Integer.parseInt(simulation.getAttribute("simulation-step")));

        // teams
        Element team = (Element)simulation.getElementsByTagName("team1").item(0);
        model.setCowsBlue(Integer.parseInt(team.getAttribute("score")));
        team = (Element)simulation.getElementsByTagName("team2").item(0);
        model.setCowsRed(Integer.parseInt(team.getAttribute("score")));

        clearModel();

        // cows
        NodeList cows = simulation.getElementsByTagName("cow");
        for (int i=0; i<cows.getLength(); i++) {
            Element cow = (Element)cows.item(i);
            int x = Integer.parseInt(cow.getAttribute("posX"));
            int y = Integer.parseInt(cow.getAttribute("posY"));
            model.add(WorldModel.COW, x, y);
        }
        
        // agents
        NodeList ags = simulation.getElementsByTagName("agent");
        for (int i=0; i<ags.getLength(); i++) {
            Element ag = (Element)ags.item(i);
            int x = Integer.parseInt(ag.getAttribute("posX"));
            int y = Integer.parseInt(ag.getAttribute("posY"));
            if (ag.getAttribute("team").equals("participant")) {
                model.add(WorldModel.AGENT, x, y);
            } else { 
                model.add(WorldModel.ENEMY, x, y);
            }
        }        
    }
    
    void clearModel() {
        for (int i = 0; i <  model.getWidth(); i++) {
            for (int j = 0; j < model.getHeight(); j++) {
                if (model.hasObject(WorldModel.AGENT, i, j) || model.hasObject(WorldModel.COW, i, j) || model.hasObject(WorldModel.ENEMY, i, j)) {
                    model.set(WorldModel.CLEAN, i, j);
                }
            }
        }
    }
    
    public void addObject(int object, int x, int y) {
        model.add(object, x, y);
    }
    
    public WorldModel getModel() {
        return model;
    }
    
    public void finish() {
        view.dispose();
        this.interrupt();
    }
    
    public void run() {
        while (true) {
            try {
                sleep(500);
                File lastFile = getLastFile(getLastFile(massimServerBackupDir));
                if (lastFile != null) {
                    logger.info("getting scenario from "+lastFile); 
                    updateWorld(lastFile);
                }
            } catch (InterruptedException e) {
                return;
            } catch (NoSuchElementException e) {
            } catch (SAXParseException e) {  // no problem: Premature end of file.
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    public static void main(String[] args) {
        new ACViewer("/Users/jomi/bin/massim-server/backup", 70, 70).start();
    }
}
