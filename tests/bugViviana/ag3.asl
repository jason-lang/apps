/* Initial beliefs and rules */

a.
/*
With the initial belief a and without the initial goal start I get:

[ag3] Using a plan whose triggering event unifies with source(percept); the current sources for belief a are [percept,self]
[ag3] source(percept) removed, now the sources are [ag2,self]
[ag3] Using a plan whose triggering event unifies with source(percept); the current sources for belief a are [ag2,self]
[ag3] source(percept) removed, now the sources are [ag2,self]
[ag3] Using a plan whose triggering event unifies with source(ag2); the current sources for belief a are [ag2,self]
[ag3] source(ag2) removed, now the sources are [self]
*/

/* Initial goals */

//!start.

/* Plans */

@r0[atomic]
+!start <- +a. 
/*
With the initial goal start defined as above, and without the initial belief a, I get:

[ag3] Using a plan whose triggering event unifies with source(self); the current sources for belief a are [percept,self]
[ag3] source(self) removed, now the sources are [ag2,percept]
[ag3] Using a plan whose triggering event unifies with source(ag2); the current sources for belief a are [ag2,percept]
[ag3] source(ag2) removed, now the sources are [percept]
[ag3] Using a plan whose triggering event unifies with source(ag2); the current sources for belief a are [percept]
[ag3] source(ag2) removed, now the sources are [percept]
*/


@r1[atomic]
+a[source(X)] <- .findall(Y, a[source(Y)], L); .print("Using a plan whose triggering event unifies with source(", X, "); the current sources for belief a are ", L); -a[source(X)]; .findall(Z, a[source(Z)], M); .print("source(", X, ") removed, now the sources are ", M).
