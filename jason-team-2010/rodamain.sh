#/bin/bash

java -cp $( echo lib/*.jar bin/classes | sed 's/ /:/g') jade.Boot -name ac10
