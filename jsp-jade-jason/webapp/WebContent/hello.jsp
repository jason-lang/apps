<%@page import="jade.core.behaviours.OneShotBehaviour"%>
<%@page import="tweb.JadeBridge"%>
<%@page import="tweb.JspJadeAg"%>
<%@page import="java.util.*" %>
<%@page import="jade.*" %>
<%@page import="jade.wrapper.*" %>
<%@page import="jade.lang.acl.*" %>

<%@page language="java" contentType="text/html; charset=US-ASCII" pageEncoding="US-ASCII"%>

<% 

// init the page:
//     get (or create if necessary) the jade ag for this session

JspJadeAg ag = (JspJadeAg)session.getAttribute("myag"); 
try {    
    if (ag == null) {
        ContainerController cc = (ContainerController)application.getAttribute("cc");
        if (cc == null) {
            // creates the main container
            String host = "127.0.0.1";
            int port = 4456;
            out.println("starting jade container at "+host+" and port "+port+"<br/>");
            String [] args = {"local-port:"+port, "host:"+host}; //,"-container"};
            cc = jade.core.Runtime.instance().createMainContainer(new BootProfileImpl(args));
            application.setAttribute("cc", cc);
            System.out.println("Container started!");
        }
        JadeBridge b = new JadeBridge();
        AgentController agCtrl = cc.createNewAgent("snooper", "tweb.JspJadeAg", new Object[] { b });
        agCtrl.start(); // starts the JspJadeAg
        
        // wait for setup
        while (b.ag == null) {
            System.out.println("Waiting ag setup...");        
            Thread.sleep(100);
        }
                
        ag = b.ag;
        System.out.println("Snooper started!");        
        
        // add behaviours if necessary (an example follows)
        ag.addBehaviour(new OneShotBehaviour() {          
            public void action() {
                System.out.println("Jade Behaviour example");
            }
        });
        session.setAttribute("myag", ag);

        // creates a test agent that sends messages to snooper
        AgentController bob = cc.createNewAgent("bob", "tweb.Sender", new Object[] { });
        bob.start();
    }
} catch (Exception ex) {
       out.println(ex);
}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII" >
<title>Example JSP+JADE+Jason</title>
</head>
<body>
received messages:
<ul>
<%

ACLMessage m = ag.receive();
while (m != null) {
    out.println("<li>"+m+"</li>");
    
    // if the message contains the number 5, sends a message back
    if (m.getContent().indexOf("5") > 0) {
        ACLMessage r = new ACLMessage(ACLMessage.REQUEST);
        r.setContent("hello(fromJSP)");
        r.addReceiver(m.getSender());
        out.print("<li>sending message "+r+"</li>");
        ag.send(r);
    }
    
    m = ag.receive();
}
%>
</ul>
<hr/>
(press reload to see new messages)
</body>
</html>