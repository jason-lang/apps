This project exemplifies how to code an agent for ART Testbed
(http://art-testbed.net) using the AgentSpeak language as interpreted
by Jason (http://jason.sf.net) -- a BDI based language.

The main approach is
1. initial parameters (eras, agents, ...) are included in the agent as
   initial beliefs.
2. operations (like prepareOpinionRequests) are mapped to achievement
   goal in Jason.
3. the decisions of the agent are done by sending messages as usual in
   Jason: .send(sim,tell, weight_msg(A,E,R))

As an example, the file src/testbed/participants/demo.asl contains the
code in an agent coded in AgentSpeak. 

Two main classes were coded: 
. JasonARTAgent: extends the Jason agent and provides to the
  AgentSpeak code an agent architecture based on the ART platform.
. JasonARTWrapper: extends the ART Agent and delegate the operations
  to the Jason agent.


To run the example, simply type
   ant run

To see the result in the ART GUI
   ant gui

Some snapshots of the agents' mind are stored in status-JasonAgent1
directory. You may run
   ant dump-html
to transform them to an HTML format.



by
Jomi Fred Hubner
June 2008

