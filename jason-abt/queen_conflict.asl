abs(X,X):- X >= 0.
abs(X,-X):- X < 0.

conflict([_,Y],[_,Y]).
conflict([Xi,Yi],[Xj,Yj]):- math.abs(Xi-Xj) == math.abs(Yi-Yj).//abs(Xi-Xj,Ax) & abs(Yi-Yj,Ay) & Ax == Ay.

