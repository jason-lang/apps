package arch;


import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.SocketException;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;


/**
 * This class provides a very simple foundation to agents. It will only connect once (no automatic reconnection).
 * It will authenticate itself and wait for any messages. You can send ping using "sendPing" whenever
 * 
 * @author silver
 */
public abstract class ACAgent {
    
    private Logger logger = Logger.getLogger(ACAgent.class.getName());  
    
    @SuppressWarnings("serial")
    private class SocketClosedException extends Exception {}
    private int networkport;
    private String networkhost;
    private Socket socket;
    
    private InputStream inputstream;
    private OutputStream outputstream;
    
    private String username;
    private String password;
    
    private DocumentBuilderFactory documentbuilderfactory;
    private TransformerFactory transformerfactory;
    
    private boolean connected = false;
    
    public ACAgent() {
        networkhost = "localhost";
        networkport = 0;
        
        //socket = new Socket();
        documentbuilderfactory=DocumentBuilderFactory.newInstance();
        transformerfactory = TransformerFactory.newInstance();
    }
    
    public String getHost() {
        return networkhost;
    }
    public void setHost(String host) {
        this.networkhost = host;
    }
    
    public int getPort() {
        return networkport;
    }
    public void setPort(int port) {
        this.networkport=port;
    }
    
    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username=username;
    }
    
    public String getPassword() {
        return username;
    }
    public void setPassword(String password) {
        this.password=password;
    }
    
    public void sendAuthentication(String username, String password) throws IOException{
        try {
            Document doc = documentbuilderfactory.newDocumentBuilder().newDocument();
            Element root = doc.createElement("message");
            root.setAttribute("type","auth-request");
            doc.appendChild(root);
            Element auth = doc.createElement("authentication");
            auth.setAttribute("username",username);
            auth.setAttribute("password",password);
            root.appendChild(auth);
            this.sendDocument(doc);
        } catch (ParserConfigurationException e) {
            logger.log(Level.SEVERE, "unable to create new document for authentication.", e);
        }
    }

    public boolean receiveAuthenticationResult() throws IOException {
        try {
            Document doc = receiveDocument();
            Element root = doc.getDocumentElement();
            if (root==null) return false;
            if (!root.getAttribute("type").equalsIgnoreCase("auth-response")) 
                return false;
            
            NodeList nl = root.getChildNodes();
            Element authresult = null;
            for (int i=0;i<nl.getLength();i++) {
                Node n = nl.item(i);
                if (n.getNodeType()==Element.ELEMENT_NODE && n.getNodeName().equalsIgnoreCase("authentication")) {
                    authresult = (Element) n;
                    break;
                }
            }
            if (authresult.getAttribute("result").equalsIgnoreCase("ok"))
                return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public boolean doAuthentication(String username, String password) throws IOException {
        sendAuthentication(username, password);
        return receiveAuthenticationResult();
    }
    
    public byte[] receivePacket() throws IOException, SocketClosedException {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        int read = inputstream.read();
        while (read!=0) {
            if (read==-1) {
                throw new SocketClosedException(); 
            }
            buffer.write(read);
            read = inputstream.read();
        }
        return buffer.toByteArray();
    }
    
    public Document receiveDocument() throws SAXException { // , IOException, ParserConfigurationException, SocketClosedException {
        try {
            byte[] raw = receivePacket();
            Document doc = documentbuilderfactory.newDocumentBuilder().parse(new ByteArrayInputStream(raw));
            return doc;
        } catch (SocketClosedException e) {
            logger.log(Level.SEVERE, "Socket was closed:"+e);
            connected = false;
        } catch (SocketException e) {
            logger.log(Level.SEVERE, "Socket exception:"+e);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "ACAgent receiveDocument exception", e);
        }
        /*
        try {
            if (logger.isLoggable(Level.FINE)) {
                ByteArrayOutputStream temp = new ByteArrayOutputStream();
                transformerfactory.newTransformer().transform(new DOMSource(doc),new StreamResult(temp));
                logger.fine("Received message:\n"+temp.toString());
            }
        } catch (Exception e) {}
        */
        return null;
    }

    protected boolean connect() {
        connected = false;
        try {
            //socketaddress = new InetSocketAddress(networkhost,networkport);
            socket = new Socket(networkhost,networkport);//socket.connect(socketaddress);
            inputstream  = socket.getInputStream();
            outputstream = socket.getOutputStream();

            if (doAuthentication(username, password)) {
                processLogIn();
                connected = true;
            } else {
                logger.log(Level.SEVERE, "authentication failed");
            }                   
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Connection exception "+e);
        }           
        return connected;
    }
    
    public boolean isConnected() {
        return connected;
    }
    
    public boolean processMessage(Element el_message) {
        String type = el_message.getAttribute("type");
        if (type.equals("request-action") || type.equals("sim-start") || type.equals("sim-end")) {
            long deadline = 0;
            long currenttime = 0;
            try {
                currenttime = Long.parseLong(el_message.getAttribute("timestamp"));
            } catch (NumberFormatException e) {
                logger.log(Level.SEVERE,"number format invalid",e);
                return true;
            }

            // get perception
            Element el_perception = null;
            NodeList nl = el_message.getChildNodes();
            String infoelementname ="perception";
            if (type.equals("request-action")) {
                infoelementname = "perception";
            } else if (type.equals("sim-start")) {
                infoelementname = "simulation";
            } else if (type.equals("sim-end")) {
                infoelementname = "sim-result";
            }

            for (int i=0;i<nl.getLength();i++) {
                Node n = nl.item(i);
                if (n.getNodeType()==Element.ELEMENT_NODE && n.getNodeName().equalsIgnoreCase(infoelementname)) {
                    if (el_perception==null) {
                        el_perception = (Element) n;
                        break;
                    }
                }
            }

            if (type.equals("request-action")) {
                try {
                    deadline = Long.parseLong(el_perception.getAttribute("deadline"));
                } catch (NumberFormatException e) {
                    logger.log(Level.SEVERE,"number format invalid",e);
                    return true;
                }
                processRequestAction(el_perception, currenttime, deadline);

            } else if (type.equals("sim-start")) {
                processSimulationStart(el_perception, currenttime);

            } else if (type.equals("sim-end")) {
                processSimulationEnd(el_perception, currenttime);
            }
            

        } else if (type.equals("pong")) {
            NodeList nl = el_message.getChildNodes();
            for (int i=0;i<nl.getLength();i++) {
                Node n = nl.item(i);
                if (n.getNodeType()==Element.ELEMENT_NODE && n.getNodeName().equalsIgnoreCase("payload")) {
                    processPong(((Element)n).getAttribute("value"));
                    return true;
                }
            }
        }
        return true;
    }

    public abstract void processSimulationStart(Element perception, long currenttime);

    public abstract void processRequestAction(Element perception, long currenttime, long deadline);
    
    public abstract void processSimulationEnd(Element result, long currenttime);
    
    public void processPong(String pong) {
        logger.info("---#-#-#-#-#-#-- processPong("+pong+") --#-#-#-#-#-#---");
    }
    
    public void processLogIn() {
        logger.info("---#-#-#-#-#-#-- login --#-#-#-#-#-#---");
    }

    Object syncSend = new Object();
    
    public void sendDocument(Document doc)  {
        try {
            ByteArrayOutputStream temp = new ByteArrayOutputStream();
            transformerfactory.newTransformer().transform(new DOMSource(doc),new StreamResult(temp));
            if (logger.isLoggable(Level.FINE)) logger.fine("Sending:"+temp.toString());
            synchronized (syncSend) {
                transformerfactory.newTransformer().transform(new DOMSource(doc),new StreamResult(outputstream));
                outputstream.write(0);
                outputstream.flush();
            }
        } catch (TransformerConfigurationException e) {
            logger.log(Level.SEVERE, "transformer config error" ,e);
        } catch (TransformerException e) {
            logger.log(Level.SEVERE,"transformer error error",e);
        } catch (IOException e) {
            logger.log(Level.SEVERE,"error in sendDocument -- reconnect",e);
            connect();
        }
    }
    
    public void sendPing(String ping) throws IOException {
        Document doc = null;
        try {
            doc = documentbuilderfactory.newDocumentBuilder().newDocument();
        } catch (ParserConfigurationException e) {
            logger.log(Level.SEVERE,"parser config error",e);
            return;
        }
        try {
            Element root = doc.createElement("message");
            doc.appendChild(root);
            root.setAttribute("type","ping");
            Element payload = doc.createElement("payload");
            payload.setAttribute("value",ping);
            root.appendChild(payload);
            sendDocument(doc);
        } catch (Exception e) {
            logger.log(Level.SEVERE,"error seding ping "+e);            
        }
    }
}
