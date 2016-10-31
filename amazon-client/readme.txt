This application shows how to program an Internal Action that
access the Amazon Web Service.

Axis (http://ws.apache.org/axis) is used to generate proxy 
classes for this WS. So the lib directory of this example includes 
all jar files that comes with Axis.

Requirements to run this application:
. Jason >= 1.0
. Ant >= 1.6.1 (to generate proxy classes from WSDL)
. If you are under an HTTP proxy, you have to edit the IA 
  implementation (file myPkg/searchAmazon.java) and uncomment/edit 
  the following lines 
	//System.setProperty("http.proxyHost", "myProxyHost");
  	//System.setProperty("http.proxyPort", "8080");


Steps to run this application:
1. Using Ant:
       ant -f bin/build.xml run

2. Using JasonIDE: open this project and simple run the MAS. 


The output will be something like:

-----------	
waiting the amazon WebService...

Programming Multi-Agent Systems in AgentSpeak using Jason (Wiley Series in Agent Technology)
      by ["Rafael H. Bordini","Jomi Fred HŸbner","Michael Wooldridge"]
      Price: 100


Multi-Agent Programming: Languages, Platforms and Applications (Multiagent Systems, Artificial Societies, and Simulated Organizations)
      by ["Rafael  H. Bordini","Mehdi Dastani","JŸrgen Dix","Amal El Fallah Seghrouchni"]
      Price: 109
....

To generate the stubs from WSDL:
    ant -f ws-build.xml wsdl2java
    
