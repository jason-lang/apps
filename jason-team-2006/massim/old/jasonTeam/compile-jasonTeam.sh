#!/bin/sh

# this file was generated by Jason

export PATH="/bin":$PATH

echo -n "        compiling user classes..."
# compile files [jasonteam/ClimaArchitecture]
# on [jasonteam]
javac -classpath .:"/lp/home/jomi/programming/cvs/Jason/bin/jason.jar":"/lp/home/jomi/clima-contest/jasonTeam/.":"$CLASSPATH"  jasonteam/*.java

chmod u+x *.sh
echo ok
