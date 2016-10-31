// a in project testeWait.mas2j
demo.
+demo : true
  <- .print("start");
     //.send(b,tell,a(10));
     !!t(0); 
     .wait({+p(Y)}); 
     .print("Y=",Y);
     !!t(0); 
     .wait({+!t(5)}); 
     .print("ok t5");
     !!esperaC;
     .print(a); .print(b); // do something to esperaC enter in wait
     do.
     
+!esperaC : true
  <- .print("esperando c");
     .wait({+c(Z)},4000);
     .print("ok,Z=",Z);
	 .wait(1000);
	 .stopMAS.
     
+c(Z) : true <- .print("recebi c ",Z).

+!t(X) : X > 10 <- +p(30).
+!t(X)          <- !!t(X+1).
