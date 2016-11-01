get_next_agent_token(Agent) :-
    .my_name(MyName) & 
    friend(MyName, _, _, 24) & //24 because the saboteurs can't attend the swarm. They must continue disturbing the enemy
    friend(Agent, _, _, 1).

get_next_agent_token(Agent) :-
    .my_name(MyName) &
    friend(MyName, _, _, MyPriority) &
    friend(Agent, _, _, MyPriority + 1).
    
/* Inc the token and send to the other agent */
+!sendToken(S):
    token(K) & K <= S & get_next_agent_token(NextAgent)
<-
    .abolish(token(_));
    .send(NextAgent, tell, token(S+1));
    .print("Sent token to ", NextAgent).
+!sendToken(S).

/* Forward the same token */
+!forwardToken(S):
    token(_) & get_next_agent_token(NextAgent)
<-
    .abolish(token(_));
    .send(NextAgent, tell, token(S));
    .print("Forwarding token to ", NextAgent).
+!forwardToken(S).

/* Create the token */
+!createToken:
    .my_name(MyName) & friend(MyName, _, _, 1)
<-
    +token(0);
    .print("Created token").
+!createToken.    

/* 
 * If I'm disabled I don't need to token. 
 * If I'm a explorer and there is still some vertices to probe, I also don't need the token
 * If I'm a repairer and I have an appointment with some agent, I also don't need the token
 */
+token(S):
    (
    	is_disabled  
    | 
    	.my_name(MyName) & friend(MyName, _, explorer, _) & not noMoreVertexToProbe
    | 
    	.my_name(MyName) & friend(MyName, _, repairer, _) & busy(_)
    ) & not lastToken(S) 
<-
    .abolish(lastToken(_));
    +lastToken(S);
    !forwardToken(S);
    .print("Received token to step ", S, " but forwarding it because I'm disabled").
    
/* I received the token again, so no one needs the token for step S */
+token(S):
    lastToken(S)
<-
    .print("Received token to step ", S, " I need to forward it, but I received it again! Let's wait next step.").

/* I got the token to step S */
+token(S) <-
    .abolish(lastToken(_));
    +lastToken(S);
    .print("Received token to step ", S).
    