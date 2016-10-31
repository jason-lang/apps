#!/bin/sh

# runs only one agent (used to test)

java -Djava.util.logging.config.file=logging.properties \
     -classpath ~/jason.jar:. \
     jasonteam.ClimaArchitecture
