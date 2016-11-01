#!/bin/bash

# source server header
source server-header.sh

# Additional settings
configs=$( ls ${conf}* )
resultPage=false;
testServerMode=false;

runServer
