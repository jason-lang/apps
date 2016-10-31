#!/bin/sh

java -cp lib/jason.jar:lib/search.jar:. \
  jason.infra.centralised.RunCentralisedMAS \
  Local-JasonTeam.mas2j
