// Agent controller in project manufacture.mas2j

{ include("common.asl") }

/* Initial beliefs and rules */

/* Initial goals */

/* Plans */

// Initially, join ORA4MAS, focus on the group status, and adopt a role in a group
+!join_and_play(GroupName, RoleName)
  <- !in_ora4mas;
     lookupArtifact(GroupName, GroupId);
     focus(GroupId);
     adoptRole(RoleName)[artifact_id(GroupId)].

// Then, just do whatever told by the organisation
+!G[scheme(S)] <- G; .print("Doing ", G, " - Scheme ", S).

